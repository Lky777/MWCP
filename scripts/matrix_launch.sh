#!/usr/bin/env bash
set -euo pipefail

# 1. general final filterlist
{
  printf '%s\n'     "[Adblock Plus 2.0]"     "! Title: MobiListChina"     "! Description: blocker for Chinese mobile site"     "! Version: $(date +%Y%m%d%H%M)"     "! Last modified: $(date -u +"%d %b %Y %H:%M UTC")"     "! Expires: 1 day"     "! Homepage: https://github.com/Lky777/MWCP/"     "! ---------------------------------"
  grep -v -e '^!' -e '^$' -e '^[[:space:]]*$' rules/matrix.txt | sort -u
} > rules/MobiListChina.txt
rule_count=$(grep -v -c -e '^!' rules/MobiListChina.txt)
rm -f rules/matrix.txt
