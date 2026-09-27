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
finish
