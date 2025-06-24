#!/usr/bin/env bash
set -euo pipefail

cat rules/dragon_add.txt >> rules/dragon.txt
grep -vFf rules/dragon_del.txt rules/dragon.txt > rules/tmp.txt && \
mv rules/tmp.txt rules/dragon.txt

LC_ALL=C sort -u -o rules/dragon.txt rules/dragon.txt
