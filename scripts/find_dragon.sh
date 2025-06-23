#!/usr/bin/env bash
set -eo pipefail
set -o nounset

rm -rf rules/
mkdir -p rules/

wget -P rules/ https://raw.githubusercontent.com/Lky777/MWCP/main/rules/fish_dragon.txt
wget -P rules/ https://raw.githubusercontent.com/Lky777/MWCP/main/rules/regular_link.txt

# figure out adservers
sort -u rules/fish_dragon.txt -o rules/fish_dragon.sorted
sort -u rules/regular_link.txt -o rules/regular_link.sorted
comm -23 rules/fish_dragon.sorted rules/regular_link.sorted > rules/pre_need_pick.txt
mv rules/pre_need_pick.txt rules/need_pick.txt

# Git
git config --global user.name "GitHub Actions"
git config --global user.email "actions@github.com"
#
if [[ ! -f "rules/need_pick.txt" ]] || \
   [[ -n $(git status --porcelain rules/need_pick.txt) ]]; then
    git add rules/need_pick.txt
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
