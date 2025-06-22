#!/usr/bin/env bash
set -euo pipefail

# init
rm -rf rules/
mkdir -p rules/

# DL
wget -P rules/ https://raw.githubusercontent.com/Lky777/MWCP/main/rules/surfing.txt
wget -P rules/ https://raw.githubusercontent.com/Lky777/MWCP/main/rules/sand_wash.txt

# sort
sort -u rules/surfing.txt -o rules/surfing.sorted
sort -u rules/sand_wash.txt -o rules/sand_wash.sorted

# figure out unique line of sand_wash.sorted（not in surfing.sorted）
comm -23 rules/sand_wash.sorted rules/surfing.sorted > rules/sand.filtered
mv rules/sand.filtered rules/asservs.txt
sed -i 's/^/||/' rules/asservs.txt
sed -i 's/$/^/' rules/asservs.txt

# Git
git config --global user.name "GitHub Actions"
git config --global user.email "actions@github.com"
if ! git diff --quiet -- rules/asservs.txt; then
  git add rules/asservs.txt
  git commit -m "Auto-update: $(date -u +'%Y-%m-%d %H:%M UTC')"
  git push
  echo "✓ Changes committed"
else
  echo "✓ Nothing to commit, no rule changes"
fi
