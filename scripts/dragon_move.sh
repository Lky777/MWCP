#!/usr/bin/env bash
set -euo pipefail

sort rules/dragon_add.txt
sort rules/dragon_del.txt
cat rules/dragon_add.txt >> rules/dragon.txt
sort rules/dragon.txt
comm -23 rules/dragon.txt rules/dragon_del.txt > rules/dragon.txt

# 2. Git push
git config --global user.name "GitHub Actions"
git config --global user.email "actions@github.com"

if ! git diff --quiet -- rules/dragon.txt 2>/dev/null || [[ ! -f "rules/dragon.txt" ]]; then
    git add rules/dragon.txt &&
    git commit -m "Auto-update: $(date -u +'%Y-%m-%d %H:%M UTC')" &&
    git push
fi
