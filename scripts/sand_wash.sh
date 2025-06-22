#!/usr/bin/env bash
set -euo pipefail

RULES_DIR="rules"
SURFING_URL="https://raw.githubusercontent.com/Lky777/MWCP/main/rules/surfing.txt"
SAND_WASH_URL="https://raw.githubusercontent.com/Lky777/MWCP/main/rules/sand_wash.txt"

rm -rf "$RULES_DIR" || true
mkdir -p "$RULES_DIR"

if ! wget -q -P "$RULES_DIR" "$SURFING_URL"; then
  echo "❌ Failed to download surfing.txt"
  exit 1
fi

if ! wget -q -P "$RULES_DIR" "$SAND_WASH_URL"; then
  echo "❌ Failed to download sand_wash.txt"
  exit 1
fi

sort -u "$RULES_DIR/surfing.txt" -o "$RULES_DIR/surfing.sorted"
sort -u "$RULES_DIR/sand_wash.txt" -o "$RULES_DIR/sand_wash.sorted"

comm -23 "$RULES_DIR/sand_wash.sorted" "$RULES_DIR/surfing.sorted" > "$RULES_DIR/sand.filtered"
mv "$RULES_DIR/sand.filtered" "$RULES_DIR/asservs.txt"

sed -i 's/^/||/' "$RULES_DIR/asservs.txt"
sed -i 's/$/^/' "$RULES_DIR/asservs.txt"

git config --global user.name "GitHub Actions"
git config --global user.email "actions@github.com"

if ! git diff --quiet -- "$RULES_DIR/asservs.txt"; then
  git add "$RULES_DIR/asservs.txt"
  git commit -m "Auto-update: $(date -u +'%Y-%m-%d %H:%M UTC')"
  
  if git push; then
    echo "✓ Changes committed and pushed"
  else
    echo "❌ Failed to push changes"
    exit 1
  fi
else
  echo "✓ Nothing to commit, no rule changes"
fi