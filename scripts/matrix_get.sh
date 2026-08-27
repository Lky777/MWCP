#!/usr/bin/env bash
set -euo pipefail

# 1. init work dir
rm -rf rules/
mkdir -p rules/

# 2. dl add rules
declare -A urls=(
  [easylistchina.txt]="https://raw.githubusercontent.com/easylist/easylistchina/master/easylistchina.txt"
  [cjx.txt]="https://raw.githubusercontent.com/cjx82630/cjxlist/master/cjx-annoyance.txt"
)

for file in "${!urls[@]}"; do
  echo "DL: $file"
  tmp_file=$(mktemp -p rules/)
  if curl -fsSL "${urls[$file]}" -o "$tmp_file"; then
    mv -f "$tmp_file" "rules/$file"
    echo "√ : $file"
  else
    echo "× : $file" >&2
  fi
  rm -f "$tmp_file"
done

# 3.
find rules -name "*.txt" -exec cat {} + | sort -u > rules/matrix.txt
tr 'A-Z' 'a-z' < rules/matrix.txt > rules/matrix.tmp && mv rules/matrix.tmp rules/matrix.txt

# 4.
rm -f rules/easylistchina.txt
rm -f rules/cjx.txt
rm -f rules/matrix.tmp
