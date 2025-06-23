#!/usr/bin/env bash
set -euo pipefail

rm -rf rules/
mkdir -p rules/

wget -P rules/ https://raw.githubusercontent.com/Lky777/MWCP/main/rules/test1.txt

DOMAINS="\.(ae|ar|at|au|be|br|ca|ch|cl|co|de|dk|eg|es|eu|\
fi|fj|fr|hk|hr|ie|il|in|ir|int|it|jp|ke|kr|ma|mo|mx|my|\
ng|nl|no|nz|ph|pl|pt|ru|sa|se|sg|sk|th|tw|uk|us|vn|za)([\/[:space:]]|$)"

grep -vE "$DOMAINS" "rules/test1.txt" > "rules/fish_dragon.tmp"
mv "rules/fish_dragon.tmp" "rules/fish_dragon.txt"
echo "Finished. Removed other regional websites."

# Git
git config --global user.name "GitHub Actions"
git config --global user.email "actions@github.com"

if ! git diff --quiet -- rules/fish_dragon.txt 2>/dev/null || [[ ! -f "rules/fish_dragon.txt" ]]; then
    git add rules/fish_dragon.txt &&
    git commit -m "Auto-update: $(date -u +'%Y-%m-%d %H:%M UTC')" &&
    git push
fi