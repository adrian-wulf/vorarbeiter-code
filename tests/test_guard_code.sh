#!/usr/bin/env bash
# Hook guard-code: Brygadzista nie może edytować plików kodu.
cd "$(dirname "$0")/.." && source tests/lib.sh
ROOT=$(mktemp -d); mkdir -p "$ROOT/.claude"
hook() { # $1 = file_path → echo kod wyjścia
  jq -n --arg p "$1" '{tool_name:"Write",tool_input:{file_path:$p}}' \
    | CLAUDE_PROJECT_DIR="$ROOT" bash .claude/hooks/guard-code.sh >/dev/null 2>"$ROOT/err"; echo $?; }
assert_eq "md w roocie przechodzi"           0 "$(hook "$ROOT/GDD.md")"
assert_eq "md w podkatalogu kodu przechodzi" 0 "$(hook "$ROOT/src/README.md")"
assert_eq "względna ścieżka md"              0 "$(hook "SYSTEMS/SYSTEM_x.md")"
assert_eq ".claude/** przechodzi"            0 "$(hook "$ROOT/.claude/skills/x/SKILL.md")"
assert_eq "executor/verify.sh przechodzi"    0 "$(hook "$ROOT/executor/verify.sh")"
assert_eq "kod w docs-templates blokowany"   2 "$(hook "$ROOT/docs-templates/x.gd")"
assert_eq "kod w profiles blokowany"         2 "$(hook "$ROOT/profiles/app/views.py")"
assert_eq ".gitignore przechodzi"            0 "$(hook "$ROOT/.gitignore")"
assert_eq "/tmp przechodzi"                  0 "$(hook "/tmp/brief.md.txt")"
assert_eq ".gd blokowany"                    2 "$(hook "$ROOT/player/player.gd")"
assert_eq ".cs blokowany"                    2 "$(hook "$ROOT/Assets/Scripts/Player.cs")"
assert_eq ".ts względny blokowany"           2 "$(hook "src/index.ts")"
assert_eq ".tscn blokowany"                  2 "$(hook "$ROOT/main.tscn")"
hook "$ROOT/a.py" >/dev/null
assert_contains "komunikat po polsku" "Brygadzista nie pisze kodu" "$(cat "$ROOT/err")"
touch "$ROOT/.claude/allow-code"
assert_eq "allow-code odblokowuje"           0 "$(hook "$ROOT/a.py")"
rm "$ROOT/.claude/allow-code"
assert_eq "brak file_path → przepuść"        0 "$(echo '{"tool_input":{}}' | CLAUDE_PROJECT_DIR="$ROOT" bash .claude/hooks/guard-code.sh; echo $?)"

# Normalizacja ścieżek: projekt poza /tmp (żeby wyjątek /tmp nie maskował wyników)
R2=$(mktemp -d -p "$HOME" .guard-test.XXXXXX); mkdir -p "$R2/.claude" "$R2/src" "$R2/executor"
ln -s "$R2" "$R2.link"
hook2() { # $1 = CLAUDE_PROJECT_DIR, $2 = file_path
  jq -n --arg p "$2" '{tool_input:{file_path:$p}}' | CLAUDE_PROJECT_DIR="$1" bash .claude/hooks/guard-code.sh >/dev/null 2>&1; echo $?; }
assert_eq "root z końcowym / — absolutna ścieżka executor" 0 "$(hook2 "$R2/" "$R2/executor/verify.sh")"
assert_eq "root z końcowym / — kod blokowany"             2 "$(hook2 "$R2/" "$R2/src/a.py")"
assert_eq "root przez symlink, ścieżka rzeczywista"        0 "$(hook2 "$R2.link" "$R2/executor/verify.sh")"
assert_eq "prefiks ./ przechodzi"                          0 "$(hook2 "$R2" "./executor/run.sh")"
assert_eq ".. z docs-templates do kodu blokowany"          2 "$(hook2 "$R2" "docs-templates/../src/a.py")"
assert_eq ".. z .claude do kodu blokowany"                 2 "$(hook2 "$R2" "$R2/.claude/../src/a.py")"
assert_eq "/tmp/.. do projektu blokowany"                  2 "$(hook2 "$R2" "/tmp/..$R2/src/a.py")"
out=$(jq -n '{tool_input:{file_path:"src/a.py"}}' | env -u HOME CLAUDE_PROJECT_DIR="$R2" bash .claude/hooks/guard-code.sh 2>&1; echo "rc=$?")
assert_contains "brak HOME — nadal blokuje" "rc=2" "$out"
NOJQ=$(mktemp -d); for b in bash cat env mkdir dirname; do ln -s "$(command -v $b)" "$NOJQ/$b"; done
out=$(echo '{"tool_input":{"file_path":"src/a.py"}}' | PATH="$NOJQ" CLAUDE_PROJECT_DIR="$R2" "$NOJQ/bash" .claude/hooks/guard-code.sh 2>&1; echo "rc=$?")
assert_contains "brak jq — blokuje (fail-closed)" "rc=2" "$out"
assert_contains "brak jq — mówi dlaczego" "jq" "$out"
rm -rf "$R2" "$R2.link"
finish
