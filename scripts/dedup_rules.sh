#!/usr/bin/env bash

tr 'A-Z' 'a-z' < rules/combined_rules.txt > rules/combined_rules.tmp && mv rules/combined_rules.tmp rules/combined_rules.txt

sed -i '/\.gif?.*/!b; /[@~]/d' rules/combined_rules.txt
sed -i '/\/ad\//!b; /[@~]/d' rules/combined_rules.txt
sed -i '/\/ads\//!b; /[@~]/d' rules/combined_rules.txt

rm -f rules/combined_rules.tmp
echo -e ".gif?\n/ad/\n/ads/" >> rules/combined_rules.txt
