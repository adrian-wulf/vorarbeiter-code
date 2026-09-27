#!/usr/bin/env bash
# PreToolUse (Edit|Write|NotebookEdit): Vorarbeiter nie pisze kodu — kod pisze wykonawca.
# Fail-closed: gdy nie da się ocenić ścieżki (np. brak jq), edycja jest blokowana.
set -uo pipefail

block() { printf '%s\n' "$@" >&2; exit 2; }

# Ścieżka absolutna bez ".", ".." i zdublowanych "/" (leksykalnie), potem z rozwiązanymi
# symlinkami najdłuższego istniejącego przodka (plik może jeszcze nie istnieć).
normalize() {
  local p="$1" part out=() rest=""
  local IFS=/
  for part in $p; do
    case "$part" in
      ''|.) ;;
      ..) ((${#out[@]})) && unset 'out[${#out[@]}-1]' ;;
      *) out+=("$part") ;;
    esac
  done
  p="/${out[*]}"
  local dir="$p"
  while [[ "$dir" != / && ! -d "$dir" ]]; do rest="/${dir##*/}$rest"; dir="${dir%/*}"; [[ -z "$dir" ]] && dir=/; done
  dir="$(cd "$dir" 2>/dev/null && pwd -P)" || dir=/
  [[ "$dir" == / ]] && dir=""
  printf '%s%s\n' "$dir" "$rest"
}

input=$(cat)
root="${CLAUDE_PROJECT_DIR:-$PWD}"
root="$(cd "$root" 2>/dev/null && pwd -P)" || block "Vorarbeiter: nie mogę ustalić katalogu projektu ($CLAUDE_PROJECT_DIR)."
[[ -f "$root/.claude/allow-code" ]] && exit 0

command -v jq >/dev/null || block \
  "Vorarbeiter: brak programu jq — hook nie może sprawdzić ścieżki, więc blokuje edycję." \
  "Zainstaluj jq (np. apt install jq / brew install jq) i spróbuj ponownie."
path=$(jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' <<<"$input" 2>/dev/null)
[[ -z "$path" ]] && exit 0
case "$path" in /*) abs="$path" ;; *) abs="$root/$path" ;; esac
abs="$(normalize "$abs")"

if [[ "$abs" != "$root"/* ]]; then
  # Poza projektem: pliki tymczasowe (briefy) i pamięć Claude'a są dozwolone.
  tmp="$(normalize "${TMPDIR:-/tmp}")"
  case "$abs" in
    "$(normalize /tmp)"/*|"$tmp"/*) exit 0 ;;
  esac
  [[ -n "${HOME:-}" && "$abs" == "$(normalize "$HOME")"/.claude/* ]] && exit 0
fi
rel="${abs#"$root"/}"
case "$rel" in
  *.md|.claude/*|executor/*|.gitignore|.gitattributes|.antigravityignore) exit 0 ;;
esac
block "Vorarbeiter nie pisze kodu: $rel" \
  "Zleć tę zmianę wykonawcy przez executor/run.sh (patrz ORCHESTRATION.md)." \
  "Tylko jeśli użytkownik WPROST pozwolił Ci pisać kod: utwórz .claude/allow-code i usuń go po zakończeniu."
