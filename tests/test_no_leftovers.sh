#!/usr/bin/env bash
# Szablon nie może zawierać pozostałości po projekcie, z którego powstał, ani TODO/TBD.
cd "$(dirname "$0")/.." && source tests/lib.sh
hits=$(grep -rniE 'goblin|korpo-gob|kenney|burnout|godot 4\.7' --include='*.md' --include='*.sh' --include='*.json' . \
  | grep -v '^./tests/' | grep -v '^./NOTICE' | grep -v '^./.git/' || true)
assert_eq "brak pozostałości po projekcie źródłowym" "" "$hits"
placeholders=$(grep -rn 'TODO\|TBD' --include='*.md' . | grep -v '^./tests/' | grep -v '^./.git/' || true)
assert_eq "brak TODO/TBD" "" "$placeholders"
for f in .claude/skills/*/SKILL.md; do
  assert_eq "frontmatter $f" "---" "$(head -1 "$f")"
  assert_contains "name w $f" "name:" "$(sed -n '2,6p' "$f")"
  assert_contains "description w $f" "description:" "$(sed -n '2,8p' "$f")"
done
left=$(sed -E 's/\{\{[A-Z_]+\}\}/X/g' AGENTS.md | grep -n '{{' || true)
assert_eq "AGENTS.md: po wypełnieniu placeholderów nie zostaje żadne {{" "" "$left"
# Po /kickoff w projekcie nie mogą zostać pliki szablonu ani reguły ukrywające testy użytkownika
assert_eq ".antigravityignore nie ukrywa katalogów tests/" "" "$(grep -n 'tests/' .antigravityignore || true)"
cleanup=$(grep -A3 'Sprzątanie szablonu' .claude/skills/kickoff/SKILL.md)
assert_contains "kickoff usuwa tests/ szablonu" "tests/" "$cleanup"
assert_contains "kickoff zastępuje README szablonu" "README.en.md" "$cleanup"
assert_contains "kickoff pyta o licencję" "LICENSE" "$(cat .claude/skills/kickoff/SKILL.md)"
assert_contains "kickoff zapisuje ustalenia na bieżąco" "### Ustalenia" "$(cat .claude/skills/kickoff/SKILL.md ORCHESTRATION_STATE.md)"
assert_contains "NOTICE zawiera pełny tekst MIT dla skilla" "Permission is hereby granted" "$(cat NOTICE)"
finish
