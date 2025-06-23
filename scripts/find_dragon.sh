#!/usr/bin/env bash
set -eo pipefail
set -o nounset

rm -rf rules/
mkdir -p rules/

# get bigdata of sites
wget -P rules/ https://raw.githubusercontent.com/Lky777/MWCP/main/rules/fish_dragon.txt
# get bigdata of adservers
wget -P rules/ https://raw.githubusercontent.com/badmojr/1Hosts/master/Pro/adblock.txt

if [[ -f "rules/adblock.txt" ]]; then
    sed -i.bak 's/^||//;s/\^$//' rules/adblock.txt
else
    echo "adblock.txt not found" >&2
    exit 1
fi

# figure out regular links
sort -u rules/adblock.txt -o rules/adblock.sorted
sort -u rules/fish_dragon.txt -o rules/fish_dragon.sorted
comm -23 rules/fish_dragon.sorted rules/adblock.sorted > rules/pre_regular_link.txt
mv rules/pre_regular_link.txt rules/regular_link.txt

# Git
git config --global user.name "GitHub Actions"
git config --global user.email "actions@github.com"
#
if [[ ! -f "rules/regular_link.txt" ]] || \
   [[ -n $(git status --porcelain rules/regular_link.txt) ]]; then
    git add rules/regular_link.txt
    git commit -m "Auto-update: $(date -u +'%Y-%m-%d %H:%M UTC')"

    for i in {1..3}; do
        if git push; then
            echo "✓ Changes committed and pushed"
            break
        else
            echo "Push attempt $i failed" >&2
            if [[ $i -lt 3 ]]; then
                sleep 5
            else
                echo "Failed to push after 3 attempts" >&2
                exit 1
            fi
        fi
    done
else
    echo "✓ Nothing to commit, no rule changes"
fi
