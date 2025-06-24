#!/usr/bin/env bash
set -euo pipefail

tr -d '\r' < rules/dragon_del.txt > rules/dragon_del_unix.txt

# 执行删除（显式检查是否发生更改）
if grep -qFf rules/dragon_del_unix.txt rules/dragon.txt; then
  echo "Removing matched lines..."
  grep -vFf rules/dragon_del_unix.txt rules/dragon.txt > tmp.txt
  mv tmp.txt rules/dragon.txt
else
  echo "No lines to remove."
fi
cat rules/dragon_add.txt >> rules/dragon.txt
grep -vFf rules/dragon_d.txt rules/dragon.txt > tmp.txt && \
mv tmp.txt rules/dragon.txt
LC_ALL=C sort -u -o rules/dragon.txt rules/dragon.txt

# 配置 Git
git config --global user.name "GitHub Actions"
git config --global user.email "actions@github.com"

# 提交变更
git add rules/dragon.txt
if ! git diff --quiet -- rules/dragon.txt 2>/dev/null || [[ ! -f "rules/dragon.txt" ]]; then
    git add rules/dragon.txt
    git commit -m "Auto-update: $(date -u +'%Y-%m-%d %H:%M UTC')"
    git pull --rebase && git push || { echo "Push failed"; exit 1; }
fi