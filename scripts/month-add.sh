#!/usr/bin/env bash
set -e

input_file1="$(pwd)/rules/week-add.txt"
input_file2="$(pwd)/rules/month-add.txt"

sort "$input_file1" | uniq -d > "$input_file2"
truncate -s 0 "$input_file1"
