#!/usr/bin/env bash
set -euo pipefail

# 1. 初始化工作目录
rm -rf rules/
mkdir -p rules/

# 2. 克隆 EasyList 仓库
curl -L -o easylist.zip https://github.com/easylist/easylist/archive/refs/heads/master.zip
unzip -q easylist.zip
mv easylist-master easylist
rm easylist.zip
rm -rf easylist-master/

# 3. 准备 EasyList 文件
rm -f easylist/easylist/{easylist_allowlist_general_hide.txt,easylist_general_hide.txt,easylist_specific_hide.txt,easylist_specific_hide_abp.txt} &
rm -f easylist/easylist_adult/adult_specific_hide.txt
wait
mv easylist/easylist/*.txt rules/ &
mv easylist/easylist_adult/*.txt rules/ &
mv easylist/easyprivacy/{easyprivacy_allowlist_international.txt,easyprivacy_specific_international.txt,easyprivacy_thirdparty_international.txt,easyprivacy_general.txt,easyprivacy_specific.txt,easyprivacy_thirdparty.txt,easyprivacy_trackingservers.txt,easyprivacy_trackingservers_mining.txt,easyprivacy_trackingservers_thirdparty.txt} rules/ &
wait
rm -rf easylist/

# 4. 下载附加规则
declare -A urls=(
  ["easylistchina.txt"]="https://raw.githubusercontent.com/easylist/easylistchina/master/easylistchina.txt"
  ["cjx-annoyance.txt"]="https://raw.githubusercontent.com/cjx82630/cjxlist/master/cjx-annoyance.txt"
  ["rules.txt"]="https://raw.githubusercontent.com/xinggsf/Adblock-Plus-Rule/master/rule.txt"
  ["fix.txt"]="https://raw.githubusercontent.com/Lky777/MWCP/main/rules/fix.txt"
)
for file in "${!urls[@]}"; do
  curl -fsSL "${urls[$file]}" -o "rules/$file" || { echo "下载失败: $file" >&2; exit 1; }
done

# 5. 处理规则内容
#awk '/^!/ {flag=0} /^! \$document$/ {flag=1} flag' rules/easylist_adservers.txt > rules/Easylist_ads.txt
#awk '/^!/ {flag=0} /^! Third-party$/ {flag=1} flag' rules/easylist_adservers.txt >> rules/Easylist_ads.txt
#awk '/^!/ {flag=0} /^! Chinese$/ {flag=1} flag' rules/easylist_adservers.txt >> rules/Easylist_ads.txt
#awk '/^!/ {flag=0} /^! IP$/ {flag=1} flag' rules/easylist_adservers.txt >> rules/Easylist_ads.txt
#rm -f rules/easylist_adservers.txt
awk '/^!/ && /Chinese/ {flag=1; next} /^!/ {flag=0} flag' rules/easyprivacy_{allowlist,specific,thirdparty}_international.txt > rules/Easyprivacy_a.txt
rm -f rules/easyprivacy_allowlist_international.txt rules/easyprivacy_specific_international.txt rules/easyprivacy_thirdparty_international.txt
sed -i '/##+js/!{/##\|#@#\|#\?#/d}' rules/{easylistchina.txt,cjx-annoyance.txt,rules.txt}

# 6. 合并所有规则
find rules -name "*.txt" -exec cat {} + | sort -u > rules/combined_rules.txt
sed -i '
  /###cxense-recs-in-article/d
  /##\.embed-responsive-trendmd/d
  /removeparam/d
  /^\/:\/\/.*/d
  s/^\*\([\/._-]\)/\1/
  /\/\\/d
' rules/combined_rules.txt

#对规则递归去重 生成rules/dedup_rules.txt
python3 scripts/dedup_rules.py

# 7. 生成最终规则文件
{
  printf '%s\n'     "[Adblock Plus 2.0]"     "! Title: MobiListChina"     "! Description: blocker for Chinese mobile site"     "! Version: $(date +%Y%m%d%H%M)"     "! Last modified: $(date -u +"%d %b %Y %H:%M UTC")"     "! Expires: 1 day"     "! Homepage: https://github.com/Lky777/MWCP/"     "! ---------------------------------"
  grep -v -e '^!' -e '^$' -e '^[[:space:]]*$' rules/dedup_rules.txt | sort -u
} > rules/MobiListChina.txt
rule_count=$(grep -v -c -e '^!' rules/MobiListChina.txt)

# 8. Git 提交并推送
git config --global user.name "GitHub Actions"
git config --global user.email "actions@github.com"
if ! git diff --quiet -- rules/MobiListChina.txt; then
  git add rules/MobiListChina.txt
  git commit -m "Auto-update: $(date -u +'%Y-%m-%d %H:%M UTC') | Rules: $rule_count"
  git push
  echo "✓ 更新已提交"
else
  echo "✓ 无需提交，规则无变化"
fi

# 9. 刷新 jsDelivr 缓存
curl -s "https://cdn.jsdelivr.net/gh/Lky777/MWCP/rules/MobiListChina.txt?cache_bust=$(date +%s)" > /dev/null

