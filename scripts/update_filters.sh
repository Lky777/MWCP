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
  ["easylistchina.txt"]="https://raw.githubusercontent.com/easylist/easylistchina/master/easylistchina.txt"
  ["cjx-annoyance.txt"]="https://raw.githubusercontent.com/cjx82630/cjxlist/master/cjx-annoyance.txt"
  ["rules.txt"]="https://raw.githubusercontent.com/xinggsf/Adblock-Plus-Rule/master/rule.txt"
  ["adblock.txt"]="https://raw.githubusercontent.com/badmojr/1Hosts/master/Lite/adblock.txt"
  ["fix.txt"]="https://raw.githubusercontent.com/Lky777/MWCP/main/rules/fix.txt"

)
for file in "${!urls[@]}"; do
  curl -fsSL "${urls[$file]}" -o "rules/$file" || { echo "下载失败: $file" >&2; exit 1; }
done

# 5. handle text
awk '/^!/ {flag=0} /^! \$document$/ {flag=1} flag' rules/easylist_adservers.txt > rules/Easylist_ads.txt
awk '/^!/ {flag=0} /^! Third-party$/ {flag=1} flag' rules/easylist_adservers.txt >> rules/Easylist_ads.txt
awk '/^!/ {flag=0} /^! Chinese$/ {flag=1} flag' rules/easylist_adservers.txt >> rules/Easylist_ads.txt
awk '/^!/ {flag=0} /^! IP$/ {flag=1} flag' rules/easylist_adservers.txt >> rules/Easylist_ads.txt
rm -f rules/easylist_adservers.txt
awk '/^!/ && /Chinese/ {flag=1; next} /^!/ {flag=0} flag' rules/easyprivacy_{allowlist,specific,thirdparty}_international.txt > rules/Easyprivacy_a.txt
rm -f rules/easyprivacy_allowlist_international.txt rules/easyprivacy_specific_international.txt rules/easyprivacy_thirdparty_international.txt
sed -i '/##+js/!{/##\|#@#\|#\?#/d}' rules/{easylistchina.txt,cjx-annoyance.txt,rules.txt}

# 6. merge
find rules -name "*.txt" -exec cat {} + | sort -u > rules/combined_rules.txt
tr 'A-Z' 'a-z' < rules/combined_rules.txt > rules/combined_rules.tmp && mv rules/combined_rules.tmp rules/combined_rules.txt
rm -f rules/combined_rules.tmp
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
 ' rules/combined_rules.txt
 printf '%s\n' '.gif?' '/ad/' '/ads/' >> rules/combined_rules.txt
rm -f rules/Easyprivacy_a.txt

# 7. general final filterlist
{
  printf '%s\n'     "[Adblock Plus 2.0]"     "! Title: MobiListChina"     "! Description: blocker for Chinese mobile site"     "! Version: $(date +%Y%m%d%H%M)"     "! Last modified: $(date -u +"%d %b %Y %H:%M UTC")"     "! Expires: 1 day"     "! Homepage: https://github.com/Lky777/MWCP/"     "! ---------------------------------"
  grep -v -e '^!' -e '^$' -e '^[[:space:]]*$' rules/combined_rules.txt | sort -u
} > rules/MobiListChina.txt
rule_count=$(grep -v -c -e '^!' rules/MobiListChina.txt)
rm -f rules/combined_rules.txt

# 8. Git push
git config --global user.name "GitHub Actions"
git config --global user.email "actions@github.com"
if ! git diff --quiet -- rules/MobiListChina.txt; then
  git add rules/MobiListChina.txt
  git commit -m "Auto-update: $(date -u +'%Y-%m-%d %H:%M UTC') | Rules: $rule_count"
  git push
  echo "✓ Changes committed"
else
  echo "✓ Nothing to commit, no rule changes"
fi

# 9. refresh jsDelivr cache
curl -s "https://cdn.jsdelivr.net/gh/Lky777/MWCP/rules/MobiListChina.txt?cache_bust=$(date +%s)" > /dev/null

