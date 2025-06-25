#!/usr/bin/env bash
set -euo pipefail

wget -P rules/ https://raw.githubusercontent.com/Lky777/MWCP/main/rules/supple.txt
cat rules/supple.txt >> rules/matrix.txt
rm -f rules/supple.txt
