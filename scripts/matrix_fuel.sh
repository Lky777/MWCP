#!/usr/bin/env bash
set -euo pipefail

wget -P rules/ https://raw.githubusercontent.com/Lky777/MWCP/main/rules/falseblock.txt
wget -P rules/ https://raw.githubusercontent.com/Lky777/MWCP/main/rules/supple.txt

# 8. del false positives
grep -ivFf rules/falseblock.txt rules/matrix.txt > rules/matrix_small.txt
cat rules/supple.txt >> rules/matrix_small.txt
rm -f rules/falseblock.txt
rm -f rules/matrix.txt
