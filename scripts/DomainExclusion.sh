#!/usr/bin/env bash
set -e

input_file="$(pwd)/source/top100k.txt"
temp_file=$(mktemp)
awk '/\.(com|cn|net|top|xyz)$/' "$input_file" > "$temp_file" && \
mv "$temp_file" "$input_file"
