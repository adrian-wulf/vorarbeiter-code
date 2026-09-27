#!/usr/bin/env bash
# Sprawdzenia przed pętlą orkiestracji. Exit 0 = gotowe.
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/config.sh"
ok=1
say() { echo "[$1] $2"; }
command -v git >/dev/null && say OK "git" || { say BRAK "git"; ok=0; }
command -v jq  >/dev/null && say OK "jq"  || { say BRAK "jq (wymagany przez executor i hook)"; ok=0; }
if [[ "$EXECUTOR" != fake ]]; then
  if command -v "$EXECUTOR" >/dev/null; then
    say OK "wykonawca: $EXECUTOR ($("$EXECUTOR" --version 2>/dev/null | head -1))"
  else
    say BRAK "wykonawca $EXECUTOR nie jest w PATH"; ok=0
  fi
fi
if git rev-parse --git-dir >/dev/null 2>&1; then
  [[ -z "$(git status --porcelain 2>/dev/null)" ]] && say OK "czyste drzewo robocze" \
    || say UWAGA "niezacommitowane zmiany — zacommituj je przed pętlą"
else
  say BRAK "to nie jest repozytorium git"; ok=0
fi
if (( ok )); then
  probe="$(mktemp)"; log="$(mktemp)"
  echo "Odpowiedz dokładnie jednym słowem: OK. Nie używaj żadnych narzędzi i pomiń raport." >"$probe"
  EXECUTOR_TIMEOUT=180 bash "$DIR/run.sh" "$probe" read "$log"; rc=$?
  case $rc in
    0) if grep -q OK "$log"; then say OK "wykonawca odpowiada"; else say UWAGA "nietypowa odpowiedź: $(head -c 200 "$log")"; fi ;;
    3) say BRAK "limit wykonawcy wyczerpany — spróbuj później albo zmień EXECUTOR"; ok=0 ;;
    4) say BRAK "wykonawca niezalogowany — uruchom go raz ręcznie w terminalu"; ok=0 ;;
    *) say BRAK "wykonawca nie odpowiedział: $(head -c 300 "$log")"; ok=0 ;;
  esac
  rm -f "$probe" "$log"
fi
if (( ok )); then echo "Preflight: GOTOWE"; exit 0; else echo "Preflight: NIEGOTOWE"; exit 1; fi
