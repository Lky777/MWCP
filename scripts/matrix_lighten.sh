#!/usr/bin/env bash
set -euo pipefail

sed -i '/##+js/!{/##\|#@#\|#\?#/d}' rules/matrix.txt
sed -i '
  /^\/:\/\/.*/d
  /\/\\/d
  s/^\*\([\/._-]\)/\1/
  s/\/\*$/\//
  /###cxense-recs-in-article/d
  /##\.embed-responsive-trendmd/d
  /removeparam/d
  /\$ping$/d
  /^|.*third-party$/d
  s/,third-party//g
  /^\$websocket,domain/d
 ' rules/matrix.txt
sed -i '
  /\/ad\/\|\/ads\// {
     /@@\|~/!d
   }
 ' rules/matrix.txt
