#!/usr/bin/env bash
set -euo pipefail

cat rules/dragon_add.txt >> rules/dragon.txt
LC_ALL=C sort -u -o rules/dragon.txt rules/dragon.txt
grep -v -F -x -f rules/dragoan_del.txt rules/dragon.txt > rules/dragon_new.txt && \
mv rules/dragon_new.txt rules/dragon.txt
