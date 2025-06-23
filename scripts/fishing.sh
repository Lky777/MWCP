#!/usr/bin/env bash
set -euo pipefail

rm -rf rules/
mkdir -p rules/

wget -P rules/ https://raw.githubusercontent.com/Lky777/MWCP/main/rules/fish_dragon.txt
wget -P rules/ https://raw.githubusercontent.com/Lky777/MWCP/main/rules/dragon.txt

# figure out adservers
sort -u rules/fish_dragon.txt -o rules/fish_dragon.sorted
sort -u rules/dragon.txt -o rules/dragon.sorted
comm -23 rules/fish_dragon.sorted rules/dragon.sorted > rules/fishing.txt
mv rules/fishing.txt rules/fish.txt

# Git
git config --global user.name "GitHub Actions"
git config --global user.email "actions@github.com"

if ! git diff --quiet -- rules/fish.txt 2>/dev/null || [[ ! -f "rules/fish.txt" ]]; then
    git add rules/fish.txt &&
    git commit -m "Auto-update: $(date -u +'%Y-%m-%d %H:%M UTC')" &&
    git push
fi