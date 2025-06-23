#!/usr/bin/env bash
set -euo pipefail

# 确保目录和文件存在
mkdir -p rules/
touch rules/dragon_add.txt rules/dragon_del.txt rules/dragon.txt

# 更新规则文件
cat rules/dragon_add.txt >> rules/dragon.txt
grep -vFf rules/dragon_del.txt rules/dragon.txt > tmp.txt && \
mv tmp.txt rules/dragon.txt
LC_ALL=C sort -u -o rules/dragon.txt rules/dragon.txt

# 配置 Git
git config --global user.name "GitHub Actions"
git config --global user.email "actions@github.com"

# 提交变更
if ! git diff --quiet -- rules/dragon.txt 2>/dev/null || [[ ! -f "rules/dragon.txt" ]]; then
    git add rules/dragon.txt
    git commit -m "Auto-update: $(date -u +'%Y-%m-%d %H:%M UTC')"
    git pull --rebase && git push || { echo "Push failed"; exit 1; }
fi