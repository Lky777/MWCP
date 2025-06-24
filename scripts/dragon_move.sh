#!/usr/bin/env bash
set -euo pipefail

cat rules/dragon_add.txt >> rules/dragon.txt
awk 'NR==FNR {a[$0]; next} !($0 in a)' rules/dragon_del.txt rules/dragon.txt > tmp.txt
LC_ALL=C sort -u -o rules/dragon.txt rules/dragon.txt
