#!/usr/bin/env bash
# PreToolUse (Edit|Write|NotebookEdit): Brygadzista nie pisze kodu — kod pisze wykonawca.
set -uo pipefail
input=$(cat)
root="${CLAUDE_PROJECT_DIR:-$PWD}"
[[ -f "$root/.claude/allow-code" ]] && exit 0
path=$(jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' <<<"$input" 2>/dev/null)
[[ -z "$path" ]] && exit 0
case "$path" in /*) abs="$path" ;; *) abs="$root/$path" ;; esac
if [[ "$abs" != "$root"/* ]]; then
  # Poza projektem: pliki tymczasowe (briefy) i pamięć Claude'a są dozwolone.
  case "$abs" in
    /tmp/*|"${TMPDIR:-/tmp}"/*|"$HOME"/.claude/*) exit 0 ;;
  esac
fi
rel="${abs#"$root"/}"
case "$rel" in
  *.md|.claude/*|executor/*|docs-templates/*|profiles/*|.gitignore|.gitattributes|.antigravityignore) exit 0 ;;
esac
cat >&2 <<MSG
Brygadzista nie pisze kodu: $rel
Zleć tę zmianę wykonawcy przez executor/run.sh (patrz ORCHESTRATION.md).
Tylko jeśli użytkownik WPROST pozwolił Ci pisać kod: utwórz .claude/allow-code i usuń go po zakończeniu.
MSG
exit 2
