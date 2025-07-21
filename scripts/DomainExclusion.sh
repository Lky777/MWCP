#!/bin/bash
set -e

input_file="$(pwd)/source/top100k.txt"
exclusions='(ar|au|br|cn|eg|et|gh|hk|in|my|np|ph|pk|pl|tr|tw)'

temp_file=$(mktemp)
awk "!/\.edu(\\.${exclusions})?\$/" "$input_file" > "$temp_file" && \
mv "$temp_file" "$input_file"
