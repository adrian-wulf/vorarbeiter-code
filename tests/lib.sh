#!/usr/bin/env bash
# Mini-asercje dla testów szablonu.
FAILS=0
assert_eq() { if [[ "$2" == "$3" ]]; then echo "  ok  $1"; else echo "  FAIL $1: oczekiwano [$2], jest [$3]"; FAILS=$((FAILS+1)); fi; }
assert_contains() { if [[ "$3" == *"$2"* ]]; then echo "  ok  $1"; else echo "  FAIL $1: brak [$2]"; FAILS=$((FAILS+1)); fi; }
finish() { if (( FAILS > 0 )); then echo "$FAILS błędów"; exit 1; fi; echo "wszystko OK"; }
