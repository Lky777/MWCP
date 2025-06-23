#!/usr/bin/env bash
set -euo pipefail

cat rules/dragon_add.txt >> rules/dragon.txt
grep -vFf rules/dragon_del.txt rules/dragon.txt > rules/dragon.tmp && \
mv rules/dragon.tmp rules/dragon.txt
sort -u -o rules/dragon.txt rules/dragon.txt

# Git push
git config --global user.name "GitHub Actions"
git config --global user.email "actions@github.com"

if ! git diff --quiet -- rules/dragon.txt 2>/dev/null || [[ ! -f "rules/dragon.txt" ]]; then
    git add rules/dragon.txt &&
    git commit -m "Auto-update: $(date -u +'%Y-%m-%d %H:%M UTC')" &&
    git push
fi
