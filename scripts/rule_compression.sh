#!/bin/sh  # 使用更基本的shell

set -e  # 任何错误立即退出

# 参数检查
[ $# -eq 2 ] || {
    echo "Usage: $0 <filter> <target>" >&2
    exit 1
}

# 文件检查
[ -f "$1" ] && [ -f "$2" ] || {
    echo "Error: Input files missing" >&2
    exit 1
}

# 使用临时工作目录
WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

# 处理逻辑
grep -ivF -f "$1" "$2" > "$WORKDIR/output" || true
mv "$WORKDIR/output" "$2"

echo "OK"