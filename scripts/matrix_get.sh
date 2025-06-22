#!/usr/bin/env bash
set -euo pipefail

# 1. init work dir
rm -rf rules/
mkdir -p rules/

# 2. git EasyList 
git clone --depth 1 https://github.com/easylist/easylist.git

# 3. prepare EasyList txt
rm -f easylist/easylist/{easylist_allowlist_general_hide.txt,easylist_general_hide.txt,easylist_specific_hide.txt,easylist_specific_hide_abp.txt} &
rm -f easylist/easylist_adult/adult_specific_hide.txt
wait
mv easylist/easylist/*.txt rules/ &
mv easylist/easylist_adult/*.txt rules/ &
mv easylist/easyprivacy/{easyprivacy_allowlist_international.txt,easyprivacy_specific_international.txt,easyprivacy_thirdparty_international.txt,easyprivacy_general.txt,easyprivacy_specific.txt,easyprivacy_thirdparty.txt,easyprivacy_trackingservers.txt,easyprivacy_trackingservers_mining.txt,easyprivacy_trackingservers_thirdparty.txt} rules/ &
wait
rm -rf easylist/

# 4. dl add rules
declare -A urls=(
  [easylistchina.txt]="https://raw.githubusercontent.com/easylist/easylistchina/master/easylistchina.txt"
  [cjx.txt]="https://raw.githubusercontent.com/cjx82630/cjxlist/master/cjx-annoyance.txt"
  [xinggsf.txt]="https://raw.githubusercontent.com/xinggsf/Adblock-Plus-Rule/master/rule.txt"
)

for file in "${!urls[@]}"; do
  echo "DL: $file"
  tmp_file=$(mktemp -p rules/)
  if curl -fsSL "${urls[$file]}" -o "$tmp_file"; then
    mv -f "$tmp_file" "rules/$file"
    echo "√ : $file"
  else
    echo "× : $file" >&2
  fi
  rm -f "$tmp_file"
done

# 5.
awk '/^!/ {flag=0} /^! Chinese$/ {flag=1} flag' rules/easylist_adservers.txt > rules/easylist_ads.txt
rm -f rules/easylist_adservers.txt
awk '/^!/ && /Chinese/ {flag=1; next} /^!/ {flag=0} flag' rules/easyprivacy_{allowlist,specific,thirdparty}_international.txt > rules/easyprivacy_a.txt
rm -f rules/easyprivacy_allowlist_international.txt rules/easyprivacy_specific_international.txt rules/easyprivacy_thirdparty_international.txt

find rules -name "*.txt" -exec cat {} + | sort -u > rules/matrix.txt
tr 'A-Z' 'a-z' < rules/matrix.txt > rules/matrix.tmp && mv rules/matrix.tmp rules/matrix.txt

rm -f rules/easylistchina.txt
rm -f rules/cjx.txt
rm -f rules/xinggsf.txt
rm -f rules/easylist_ads.txt
rm -f rules/easyprivacy_a.txt
rm -f rules/matrix.tmp
