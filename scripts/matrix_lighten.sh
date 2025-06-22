#!/usr/bin/env bash
set -euo pipefail

sed -i '/##+js/!{/##\|#@#\|#\?#/d}' rules/matrix.txt

sed -i '
  /###cxense-recs-in-article/d
  /##\.embed-responsive-trendmd/d
  /removeparam/d
  /^\/:\/\/.*/d
  s/^\*\([\/._-]\)/\1/
  /\/\\/d
  /\.gif\?\|\/ad\/\|\/ads\// {
     /@@\|~/!d
   }
 ' rules/matrix.txt
