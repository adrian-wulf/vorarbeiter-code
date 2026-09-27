# classify <rc> <log> → echo 0 (OK) | 1 (błąd) | 3 (limit) | 4 (brak autoryzacji)
# Wzorce limitu/autoryzacji sprawdzamy TYLKO przy porażce albo pustej odpowiedzi,
# żeby słowo "rate limit" w poprawnej odpowiedzi nie zatrzymało pętli.
classify() {
  local rc="$1" log="$2"
  if [[ "$rc" -eq 0 && -s "$log" ]] && grep -q '[^[:space:]]' "$log"; then echo 0; return; fi
  if grep -Eiq 'quota|rate.?limit|RESOURCE_EXHAUSTED|(^|[^0-9])429([^0-9]|$)|usage limit|limit (reached|exceeded)' "$log" 2>/dev/null; then echo 3; return; fi
  if grep -Eiq 'sign.?in|log.?in required|unauthenticated|not authenticated|credentials|OAuth' "$log" 2>/dev/null; then echo 4; return; fi
  echo 1
}
