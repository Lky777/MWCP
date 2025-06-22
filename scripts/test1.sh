#!/usr/bin/env bash
set -euo pipefail

rm -rf rules/
mkdir -p rules/

DOMAINS="\.(hk|mo|tw|jp|kr|sg|in|my|th|vn|ph|id|il|sa|ae|uk|de|fr|it|es|nl|ch|se|no|dk|fi|ru|pl|pt|at|ie|us|ca|mx|br|ar|cl|co|au|nz|fj|za|eg|ng|ke|ma|eu|int)[[:space:]]*$"

if [ ! -f "rules/test1.txt" ]; then
    echo "错误：文件 rules/test1.txt 不存在！"
    exit 1
fi

grep -vE "$DOMAINS" "rules/test1.txt" > "rules/test1.tmp"
mv "rules/test1.tmp" "rules/test1.txt"
echo "处理完成！已删除所有行末尾是国家/地区域名的行。"

wget -P rules/ https://raw.githubusercontent.com/badmojr/1Hosts/master/Lite/adblock.txt

if [ ! -f "rules/adblock.txt" ]; then
    echo "错误：文件 rules/adblock.txt 不存在！"
    exit 1
fi

temp_file=$(mktemp)
sed -e 's/^||//' -e 's/\^$//' "rules/adblock.txt" > "$temp_file"
mv "$temp_file" "rules/adblock.txt"
echo "处理完成！已删除所有行首的 || 和行尾的 ^"

if [ ! -f "rules/test1.txt" ] || [ ! -f "rules/adblock.txt" ]; then
    echo "错误：文件 rules/test1.txt 或 rules/adblock.txt 不存在！"
    exit 1
fi

grep -vFf "rules/adblock.txt" "rules/test1.txt" > "rules/test1.tmp"
mv "rules/test1.tmp" "rules/test1.txt"
echo "处理完成！已删除 test1.txt 中所有与 adblock.txt 匹配的行。"

git config --global user.name "GitHub Actions"
git config --global user.email "actions@github.com"
if ! git diff --quiet -- rules/test1.txt; then
  git add rules/test1.txt
  git commit -m "Auto-update: $(date -u +'%Y-%m-%d %H:%M UTC')"
  git push
  echo "✓ Changes committed"
else
  echo "✓ Nothing to commit, no rule changes"
fi
