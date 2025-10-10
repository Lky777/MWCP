#!/usr/bin/env bash
set -e

input_file="$(pwd)/source/top100k.txt"
temp_file1=$(mktemp)
temp_file2=$(mktemp)

awk '/\.(com|cn|net|top|xyz)$/' "$input_file" > "$temp_file1"
awk '!/\.(gov|edu|mil)\.cn$/' "$temp_file1" > "$temp_file2"

mv "$temp_file2" "$input_file"
rm "$temp_file1"
