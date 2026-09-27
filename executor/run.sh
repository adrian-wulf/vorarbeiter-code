#!/usr/bin/env bash
# Jedyny punkt wywołania wykonawcy.
# Użycie: executor/run.sh <plik-zlecenia> <write|read> <plik-logu>
# Kody: 0 OK · 1 błąd · 3 limit/quota wykonawcy · 4 brak autoryzacji
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/config.sh"; source "$DIR/classify.sh"
brief="${1:-}"; mode="${2:-}"; log="${3:-}"
[[ -f "$brief" ]] || { echo "Brak pliku zlecenia: $brief" >&2; exit 1; }
[[ "$mode" == write || "$mode" == read ]] || { echo "Tryb musi być write albo read" >&2; exit 1; }
[[ -n "$log" ]] || { echo "Podaj plik logu" >&2; exit 1; }
mkdir -p "$(dirname "$log")"

prompt="$(cat "$brief")"$'\n\n'"$(cat "$DIR/rules.md")"
[[ -f "$DIR/rules.profile.md" ]] && prompt+=$'\n\n'"$(cat "$DIR/rules.profile.md")"
[[ "$mode" == read ]] && prompt+=$'\n\nTRYB TYLKO DO ODCZYTU: nie modyfikuj, nie twórz i nie usuwaj żadnych plików.'

raw="$(mktemp)"; trap 'rm -f "$raw"' EXIT
# `timeout` (GNU) → `gtimeout` (macOS + coreutils) → bez limitu czasu
with_timeout() {
  if command -v timeout >/dev/null; then timeout "$EXECUTOR_TIMEOUT" "$@"
  elif command -v gtimeout >/dev/null; then gtimeout "$EXECUTOR_TIMEOUT" "$@"
  else "$@"; fi
}
case "$EXECUTOR" in
  agy)
    command -v agy >/dev/null || { echo "Nie znaleziono agy w PATH" >&2; exit 1; }
    args=(-p "$prompt" --output-format json --print-timeout "${EXECUTOR_TIMEOUT}s" --dangerously-skip-permissions)
    [[ -n "$EXECUTOR_MODEL" ]] && args+=(--model "$EXECUTOR_MODEL")
    [[ "$mode" == read ]] && args+=(--sandbox)
    agy "${args[@]}" </dev/null >"$raw" 2>&1; rc=$?
    if jq -e 'has("response")' "$raw" >/dev/null 2>&1; then
      jq -r '.response // ""' "$raw" >"$log"
      [[ "$(jq -r '.status // "SUCCESS"' "$raw")" == SUCCESS ]] || rc=1
    else cp "$raw" "$log"; fi ;;
  gemini)
    # Niezweryfikowane na żywo (gemini-cli niedostępne przy tworzeniu szablonu).
    command -v gemini >/dev/null || { echo "Nie znaleziono gemini w PATH" >&2; exit 1; }
    args=(-p "$prompt"); [[ "$mode" == write ]] && args+=(--yolo)
    [[ -n "$EXECUTOR_MODEL" ]] && args+=(-m "$EXECUTOR_MODEL")
    with_timeout gemini "${args[@]}" </dev/null >"$log" 2>&1; rc=$? ;;
  codex)
    command -v codex >/dev/null || { echo "Nie znaleziono codex w PATH" >&2; exit 1; }
    sb=workspace-write; [[ "$mode" == read ]] && sb=read-only
    : >"$log"
    args=(exec --skip-git-repo-check -s "$sb" -o "$log")
    [[ -n "$EXECUTOR_MODEL" ]] && args+=(-m "$EXECUTOR_MODEL")
    with_timeout codex "${args[@]}" "$prompt" </dev/null >"$raw" 2>&1; rc=$?
    [[ $rc -ne 0 || ! -s "$log" ]] && cat "$raw" >>"$log" ;;
  fake)
    "$FAKE_EXECUTOR" "$prompt" </dev/null >"$log" 2>&1; rc=$? ;;
  *) echo "Nieznany wykonawca: $EXECUTOR (agy|gemini|codex)" >&2; exit 1 ;;
esac
exit "$(classify "$rc" "$log")"
