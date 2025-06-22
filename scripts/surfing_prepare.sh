#!/usr/bin/env bash
set -eo pipefail
set -o nounset

cleanup() {
    echo "Cleaning up temporary files..."
    rm -f rules/test1.txt
    rm -f rules/adblock.sorted
    rm -f rules/sand_wash.tmp
    rm -f rules/sand_wash.txt
    rm -f rules/sand_wash.sorted
    rm -f rules/adblock.txt.bak
    rm -f rules/pre_surfing.txt
    rm -f rules/surfing.txt
    rm -f rules/asservs.txt
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
    grep -vE "$DOMAINS" "rules/test1.txt" > "rules/sand_wash.tmp"
    mv "rules/sand_wash.tmp" "rules/sand_wash.txt"
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

# figure out regular sites--surfing.txt
sort -u rules/adblock.txt -o rules/adblock.sorted
sort -u rules/sand_wash.txt -o rules/sand_wash.sorted
comm -23 rules/sand_wash.sorted rules/adblock.sorted > rules/pre_surfing.txt
touch "rules/surfing.txt"
mv rules/pre_surfing.txt rules/surfing.txt

# figure out adservers from sand_wash
sort -u rules/surfing.txt -o rules/surfing2.sorted
comm -23 rules/sand_wash.sorted rules/surfing2.sorted > rules/asservs.filter
mv rules/asservs.filter rules/asservs.txt

# Git
git config --global user.name "GitHub Actions"
git config --global user.email "actions@github.com"

if ! git diff --quiet -- rules/surfing.txt rules/asservs.txt; then
    git add rules/surfing.txt rules/asservs.txt
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