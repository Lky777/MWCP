#!/usr/bin/env bash
set -euo pipefail
set -x  # 开启调试模式

# 初始化目录
rm -rf rules/
mkdir -p rules/

wget -P rules/ https://raw.githubusercontent.com/Lky777/MWCP/main/rules/surfing.txt
wget -P rules/ https://raw.githubusercontent.com/Lky777/MWCP/main/rules/sand_wash.txt

# 排序
sort -u rules/adblock.txt -o rules/surfing.sorted
sort -u rules/test1.txt -o rules/sand_wash.sorted

# 使用 comm 找出 sand_wash.sorted 独有的行（即不在 surfing.sorted 中的行）
comm -23 rules/sand_wash.sorted rules/surfing.sorted > rules/sand.filtered

mv rules/sand.filtered rules/adservs.txt

# 4. Git操作
if [ -n "${GITHUB_ACTIONS-}" ]; then
    git config --global user.name "GitHub Actions"
    git config --global user.email "actions@github.com"
    
    # 确保有修改才提交
    if ! git diff --quiet -- rules/adservs.txt; then
        git add rules/adservs.txt
        git commit -m "Auto-update: $(date -u +'%Y-%m-%d %H:%M UTC')"
        git push
        echo "✓ Changes committed"
    else
        echo "✓ Nothing to commit, no rule changes"
    fi
fi