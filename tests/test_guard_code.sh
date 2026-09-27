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
assert_eq "docs-templates przechodzi"        0 "$(hook "$ROOT/docs-templates/x.gd")"
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
finish
