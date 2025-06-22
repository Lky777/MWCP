#!/bin/bash

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <file1> <file2>"
    exit 1
fi

text1="$1"
text2="$2"
temp_file=$(mktemp)

if [ ! -f "$text1" ] || [ ! -f "$text2" ]; then
    echo "Error: Input files not found!"
    exit 1
fi

while IFS= read -r line; do
    if [ -n "$line" ]; then
        grep -ivF -- "$line" "$text2" > "$temp_file" || true
        mv "$temp_file" "$text2"
    fi
done < "$text1"

rm -f "$temp_file"
echo "OK"