#!/usr/bin/env bash
set -euo pipefail

cat rules/dragon_add.txt >> rules/dragon.txt
grep -vFf <(grep -v '^$' rules/dragon_del.txt) rules/dragon.txt > tmp.txt && \
mv tmp.txt rules/dragon.txt
LC_ALL=C sort -u -o rules/dragon.txt rules/dragon.txt
