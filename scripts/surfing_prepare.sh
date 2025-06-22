#!/usr/bin/env bash
set -eo pipefail
set -o nounset

cleanup() {
    echo "Cleaning up temporary files..."
    rm -f rules/adblock.sorted
    rm -f rules/test1.sorted
    rm -f rules/test1.tmp
    rm -f rules/adblock.txt.bak
    echo "Cleanup completed."
}

trap cleanup EXIT

rm -rf rules/
mkdir -p rules/

# get bigdata of sites
wget -P rules/ https://raw.githubusercontent.com/Lky777/MWCP/main/rules/test1.txt

# slim down data
DOMAINS="\.(ae|ar|at|au|be|br|ca|ch|cl|co|de|dk|eg|es|eu|\
fi|fj|fr|hk|hr|ie|il|in|ir|int|it|jp|ke|kr|ma|mo|mx|my|\
ng|nl|no|nz|ph|pl|pt|ru|sa|se|sg|sk|th|tw|uk|us|vn|za)([\/[:space:]]|$)"

if [[ -f "rules/test1.txt" ]]; then
    grep -vE "$DOMAINS" "rules/test1.txt" > "rules/test1.tmp"
    mv "rules/test1.tmp" "rules/test1.txt"
    echo "Finished. Removed other regional websites."
else
    echo "test1.txt not found" >&2
    exit 1
fi

# get bigdata of adservers
wget -P rules/ https://raw.githubusercontent.com/badmojr/1Hosts/master/Lite/adblock.txt

if [[ -f "rules/adblock.txt" ]]; then
    sed -i.bak 's/^||//;s/\^$//' rules/adblock.txt
else
    echo "adblock.txt not found" >&2
    exit 1
fi

sort -u rules/adblock.txt -o rules/adblock.sorted
sort -u rules/test1.txt -o rules/test1.sorted

# figure out regular sites--surfing.txt
comm -23 rules/test1.sorted rules/adblock.sorted > rules/test1.filtered
mv rules/test1.filtered rules/surfing.txt

# Git
git config --global user.name "GitHub Actions"
git config --global user.email "actions@github.com"

#
if ! git diff --quiet -- rules/surfing.txt; then
    git add rules/surfing.txt
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

cleanup