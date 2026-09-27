#!/usr/bin/env bash
# executor/run.sh: sklejanie zlecenia z zasadami i klasyfikacja wyniku wykonawcy.
cd "$(dirname "$0")/.." && source tests/lib.sh
T=$(mktemp -d); export EXECUTOR=fake FAKE_EXECUTOR="$T/fake.sh"
echo "Zrób X w pliku a.txt" > "$T/brief"
mk() { printf '#!/usr/bin/env bash\n%s\n' "$1" > "$FAKE_EXECUTOR"; chmod +x "$FAKE_EXECUTOR"; }

mk 'printf "%s" "$1" > '"$T"'/seen; echo "Gotowe."'
bash executor/run.sh "$T/brief" write "$T/log"; rc=$?
assert_eq "sukces → 0" 0 "$rc"
assert_contains "log ma odpowiedź" "Gotowe." "$(cat "$T/log")"
assert_contains "zlecenie przekazane" "Zrób X" "$(cat "$T/seen")"
assert_contains "doklejone stałe zasady" "STAŁE ZASADY PROJEKTU" "$(cat "$T/seen")"

bash executor/run.sh "$T/brief" read "$T/log"
assert_contains "tryb read dopisuje zakaz" "TRYB TYLKO DO ODCZYTU" "$(cat "$T/seen")"

echo "REGUŁA PROFILU XYZ" > executor/rules.profile.md
bash executor/run.sh "$T/brief" write "$T/log"
assert_contains "reguły profilu doklejone" "REGUŁA PROFILU XYZ" "$(cat "$T/seen")"
rm executor/rules.profile.md

mk 'echo "Error: RESOURCE_EXHAUSTED quota exceeded" >&2; exit 1'
bash executor/run.sh "$T/brief" write "$T/log"; assert_eq "quota → 3" 3 $?
mk 'echo "HTTP 429 Too Many Requests"; exit 1'
bash executor/run.sh "$T/brief" write "$T/log"; assert_eq "429 → 3" 3 $?
mk 'echo "Please sign in: https://accounts.google.com/..."; exit 1'
bash executor/run.sh "$T/brief" write "$T/log"; assert_eq "auth → 4" 4 $?
mk 'echo "segfault"; exit 1'
bash executor/run.sh "$T/brief" write "$T/log"; assert_eq "inny błąd → 1" 1 $?
mk 'exit 0'
bash executor/run.sh "$T/brief" write "$T/log"; assert_eq "pusta odpowiedź → 1" 1 $?
mk 'echo "Dodałem obsługę rate limit 429 w api.ts"; exit 0'
bash executor/run.sh "$T/brief" write "$T/log"; assert_eq "słowo limit przy sukcesie → 0" 0 $?

bash executor/run.sh "$T/nie-ma" write "$T/log" 2>/dev/null; assert_eq "brak pliku zlecenia → 1" 1 $?
bash executor/run.sh "$T/brief" zly "$T/log" 2>/dev/null;   assert_eq "zły tryb → 1" 1 $?
EXECUTOR=nieznany bash executor/run.sh "$T/brief" write "$T/log" 2>/dev/null; assert_eq "nieznany wykonawca → 1" 1 $?

out=$(EXECUTOR=nieistniejacy-cli bash executor/preflight.sh 2>&1); rc=$?
assert_eq "preflight bez binarki → 1" 1 "$rc"
assert_contains "preflight mówi czytelnie" "nie jest w PATH" "$out"
finish
