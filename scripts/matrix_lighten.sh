#!/usr/bin/env bash
set -euo pipefail

sed -i '/##+js/!{/##\|#@#\|#\?#/d}' rules/matrix.txt
sed -i '
  s/^\*\([\/._-]\)/\1/
  /###cxense-recs-in-article/d
  /##\.embed-responsive-trendmd/d
  /removeparam/d
  /^\/:\/\/.*/d
  /^|.*third-party$/d
  /\/\\/d
  /\.xyz\^/d
  /\.xyz\//d
 ' rules/matrix.txt
sed -i '
  /\.gif\?\|\/ad\/\|\/ads\// {
     /@@\|~/!d
   }
 ' rules/matrix.txt
