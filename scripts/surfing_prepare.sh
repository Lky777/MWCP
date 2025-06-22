#!/usr/bin/env bash
set -euo pipefail
set -x  # 开启调试模式

# 
rm -rf rules/
mkdir -p rules/

wget -P rules/ https://raw.githubusercontent.com/Lky777/MWCP/main/rules/test1.txt
DOMAINS="\.(ae|ar|at|au|br|ca|ch|cl|co|de|dk|eg|es|eu|fi|fj|fr|hk|ie|il|in|int|it|jp|ke|kr|ma|mo|mx|my|ng|nl|no|nz|ph|pl|pt|ru|sa|se|sg|th|tw|uk|us|vn|za)([[:space:]]*|$)"
grep -vE "$DOMAINS" "rules/test1.txt" > "rules/test1.tmp"
mv "rules/test1.tmp" "rules/test1.txt"
echo "Finished. Removed other regional websites."

wget -P rules/ https://raw.githubusercontent.com/badmojr/1Hosts/master/Lite/adblock.txt
sed -i 's/^||//;s/\^$//' rules/adblock.txt

# sort firstly
sort -u rules/adblock.txt -o rules/adblock.sorted
sort -u rules/test1.txt -o rules/test1.sorted

# find ou unique line in test1.sorted （not in adblock.sorted）
comm -23 rules/test1.sorted rules/adblock.sorted > rules/test1.filtered
mv rules/test1.filtered rules/surfing.txt

# Git push
git config --global user.name "GitHub Actions"
git config --global user.email "actions@github.com"
if ! git diff --quiet -- rules/surfing.txt; then
  git add rules/surfing.txt
  git commit -m "Auto-update: $(date -u +'%Y-%m-%d %H:%M UTC')"
  git push
  echo "✓ Changes committed"
else
  echo "✓ Nothing to commit, no rule changes"
fi
