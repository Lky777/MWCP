#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Rules Compressing..."
    exit 1
fi

text1="$1"
text2="$2"
temp_file=$(mktemp)

while IFS= read -r line; do
    if [ -n "$line" ]; then
        grep -ivF -- "$line" "$text2" > "$temp_file"
        mv "$temp_file" "$text2"
    fi
done < "$text1"
rm -f "$temp_file"
echo "OK"


