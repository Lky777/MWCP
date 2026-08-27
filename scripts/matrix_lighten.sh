#!/usr/bin/env bash
set -euo pipefail

sed -i '
  /##+js/!{/##\|#@#\|#\?#/d}
  /^\/:\/\/.*/d
  /\/\\/d
  s/^\*\([\/._-]\)/\1/
  s/\/\*$/\//
  /\/ad\/\|\/ads\// {
     /@@\|~/!d
   }
  /removeparam/d
  /\$ping$/d
  /^\$websocket,domain/d
  /^\[Adblock Plus 2\.0/Id
  /###cxense-recs-in-article/d
  /##\.embed-responsive-trendmd/d
' rules/matrix.txt
