#!/usr/bin/env bash
# Uruchamia wszystkie testy szablonu.
set -uo pipefail
cd "$(dirname "$0")/.."
rc=0
for t in tests/test_*.sh; do echo "== $t"; bash "$t" || rc=1; done
exit $rc
