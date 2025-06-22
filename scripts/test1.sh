#!/usr/bin/env bash
set -euo pipefail
set -x  # 开启调试模式
# 初始化目录
rm -rf rules/
mkdir -p rules/

wget -P rules/ https://raw.githubusercontent.com/Lky777/MWCP/main/rules/test1.txt
DOMAINS="\.(hk|mo|tw|jp|kr|sg|in|my|th|vn|ph|id|il|sa|ae|uk|de|fr|it|es|nl|ch|se|no|dk|fi|ru|pl|pt|at|ie|us|ca|mx|br|ar|cl|co|au|nz|fj|za|eg|ng|ke|ma|eu|int)[[:space:]]*$"

# 检查文件是否存在
check_file() {
    if [ ! -f "$1" ]; then
        echo "错误：文件 $1 不存在！" >&2
        exit 1
    fi
}

# 1. 处理test1.txt
check_file "rules/test1.txt"

# 如果文件非空才处理
if [ -s "rules/test1.txt" ]; then
    grep -vE "$DOMAINS" "rules/test1.txt" > "rules/test1.tmp"
    mv "rules/test1.tmp" "rules/test1.txt"
    echo "处理完成！已删除所有行末尾是国家/地区域名的行。"
else
    echo "警告：rules/test1.txt 为空，跳过域名过滤"
fi

# 2. 下载并处理adblock.txt
echo "正在下载 adblock.txt..."
if ! wget --tries=3 --timeout=30 -q -P rules/ https://raw.githubusercontent.com/badmojr/1Hosts/master/Lite/adblock.txt; then
    echo "错误：下载 adblock.txt 失败！" >&2
    exit 1
fi

temp_file=$(mktemp)
sed -e 's/^||//' -e 's/\^$//' "rules/adblock.txt" > "$temp_file"
mv "$temp_file" "rules/adblock.txt"


if [ -s "rules/adblock.txt" ] && [ -s "rules/test1.txt" ]; then
    grep -vFf "rules/adblock.txt" "rules/test1.txt" > "rules/test1.tmp"
    mv "rules/test1.tmp" "rules/test1.txt"

# 4. Git操作
if [ -n "${GITHUB_ACTIONS-}" ]; then
    git config --global user.name "GitHub Actions"
    git config --global user.email "actions@github.com"
    
    # 确保有修改才提交
    if ! git diff --quiet -- rules/test1.txt; then
        git add rules/test1.txt
        git commit -m "Auto-update: $(date -u +'%Y-%m-%d %H:%M UTC')"
        git push
        echo "✓ Changes committed"
    else
        echo "✓ Nothing to commit, no rule changes"
    fi