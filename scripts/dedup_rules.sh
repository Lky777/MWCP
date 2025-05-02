#!/usr/bin/env bash

tr 'A-Z' 'a-z' < rules/combined_rules.txt > rules/combined_rules.tmp && mv rules/combined_rules.tmp rules/combined_rules.txt

awk '!(
    (/\/ad\// || /\/ads\// || /\.gif\?/) &&
    !(/@/ || /~/)
)' rules/combined_rules.txt > rules/combined_rules.tmp && \
mv rules/combined_rules.tmp rules/combined_rules.txt

rm -f rules/combined_rules.tmp
echo -e ".gif?\n/ad/\n/ads/" >> rules/combined_rules.txt
