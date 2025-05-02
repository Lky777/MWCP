#!/usr/bin/env bash

tr 'A-Z' 'a-z' < rules/combined_rules.txt > rules/combined_rules.tmp && mv rules/combined_rules.tmp rules/combined_rules.txt
# index() 检查是否包含特定字符串（无需转义）
awk '!(
    (index($0, ".gif?") || 
     index($0, "/ad/") || 
     index($0, "/ads/")) 
    && !/@/ 
    && !/~/
)' combined_rules.txt > tmp && mv tmp combined_rules.txt

echo -e ".gif?\n/ad/\n/ads/" >> rules/combined_rules.txt
