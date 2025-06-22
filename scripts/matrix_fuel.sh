#!/usr/bin/env bash
set -euo pipefail
#
wget -P rules/ https://raw.githubusercontent.com/Lky777/MWCP/main/rules/supple.txt
wget -P rules/ https://raw.githubusercontent.com/Lky777/MWCP/main/rules/asservs.txt
wget -P rules/ https://raw.githubusercontent.com/Lky777/MWCP/main/rules/falseblock.txt
#
cat rules/asservs.txt >> rules/matrix.txt
cat rules/supple.txt >> rules/matrix.txt
grep -ivFf rules/falseblock.txt rules/matrix.txt > rules/matrix_small.txt
#
rm -f rules/supple.txt
rm -f rules/asservs.txt
rm -f rules/matrix.txt
rm -f rules/falseblock.txt
