#!/usr/bin/env bash
set -euo pipefail

# 1. general final filterlist
{
  printf '%s\n'     "[Adblock Plus 2.0]"     "! Title: MobiList"     "! Description: blocker for mobile internet"     "! Version: $(date +%Y%m%d%H%M)"     "! Last modified: $(date -u +"%d %b %Y %H:%M UTC")"     "! Expires: 1 day"     "! Homepage: https://github.com/Lky777/MWCP/"     "! ---------------------------------"
  grep -v -e '^!' -e '^$' -e '^[[:space:]]*$' rules/matrix.txt | sort -u
} > rules/MobiList.txt
rule_count=$(grep -v -c -e '^!' rules/MobiList.txt)
rm -f rules/matrix.txt
