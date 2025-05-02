#!/bin/bash

INPUT_FILE="rules/combined_rules.txt"
OUTPUT_FILE="rules/dedup_rules.txt"

echo "[INFO] 开始规则去重处理..."

start_time=$(date +%s)

# 预处理：转小写、去前后空格、去空行，按长度排序
mapfile -t lines < <(
  awk '{print tolower($0)}' "$INPUT_FILE" |
  sed 's/^[[:space:]]*//;s/[[:space:]]*$//' |
  grep -v '^$' |
  awk '{ print length, $0 }' | sort -n | cut -d' ' -f2-
)

keep=()

for line in "${lines[@]}"; do
  is_redundant=false
  for kept in "${keep[@]}"; do
    # 使用 grep -Fq 进行固定字符串查找（防止模式解释）
    echo "$kept" | grep -Fqi "$line"
    if [[ $? -eq 0 && "$line" != "$kept" ]]; then
      is_redundant=true
      break
    fi
  done

  if ! $is_redundant; then
    keep+=("$line")
  fi
done

# 输出结果
mkdir -p "$(dirname "$OUTPUT_FILE")"
printf "%s\n" "${keep[@]}" > "$OUTPUT_FILE"

end_time=$(date +%s)
elapsed=$((end_time - start_time))
echo "[INFO] 去重完成，耗时 ${elapsed} 秒"
