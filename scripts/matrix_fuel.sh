#!/usr/bin/env bash
set -euo pipefail

wget -P rules/ https://raw.githubusercontent.com/Lky777/MWCP/main/rules/supple.txt
wget -P rules/ https://raw.githubusercontent.com/Lky777/MWCP/main/rules/adservers.txt
sed -i 's/^/||/; s/$/^/' rules/adservers.txt
cat rules/supple.txt >> rules/matrix.txt
cat rules/adservers.txt >> rules/matrix.txt
sort -u rules/matrix.txt -o rules/matrix.txt
rm -f rules/supple.txt
rm -f rules/adservers.txt