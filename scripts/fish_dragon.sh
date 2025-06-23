#!/usr/bin/env bash
set -eo pipefail

rm -rf rules/
mkdir -p rules/

#
wget -P rules/ https://raw.githubusercontent.com/Lky777/MWCP/main/rules/test1.txt

#
DOMAINS="\.(ae|ar|at|au|be|br|ca|ch|cl|co|de|dk|eg|es|eu|\
fi|fj|fr|hk|hr|ie|il|in|ir|int|it|jp|ke|kr|ma|mo|mx|my|\
ng|nl|no|nz|ph|pl|pt|ru|sa|se|sg|sk|th|tw|uk|us|vn|za)([\/[:space:]]|$)"

if [[ -f "rules/test1.txt" ]]; then
    grep -vE "$DOMAINS" "rules/test1.txt" > "rules/fish_dragon.tmp"
    mv "rules/fish_dragon.tmp" "rules/fish_dragon.txt"
    echo "Finished. Removed other regional websites."
else
    echo "test1.txt not found" >&2
    exit 1
fi

# Git
git config --global user.name "GitHub Actions"
git config --global user.email "actions@github.com"
#
if [[ ! -f "rules/fish_dragon.txt" ]] || \
   [[ -n $(git status --porcelain rules/fish_dragon.txt) ]]; then
    git add rules/fish_dragon.txt
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
