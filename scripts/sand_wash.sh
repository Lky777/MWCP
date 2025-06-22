#!/usr/bin/env bash
set -euo pipefail

# init
rm -rf rules/
mkdir -p rules/

# DL
wget -P rules/ https://raw.githubusercontent.com/Lky777/MWCP/main/rules/surfing.txt
wget -P rules/ https://raw.githubusercontent.com/Lky777/MWCP/main/rules/sand_wash.txt

# sort
sort -u rules/surfing.txt -o rules/surfing.sorted
sort -u rules/sand_wash.txt -o rules/sand_wash.sorted

# figure out unique line of sand_wash.sorted（not in surfing.sorted）
comm -23 rules/sand_wash.sorted rules/surfing.sorted > rules/sand.filtered
mv rules/sand.filtered rules/asservs.txt
sed -i 's/^/||/' rules/asservs.txt
sed -i 's/$/^/' rules/asservs.txt

# Git
git config --global user.name "GitHub Actions"
git config --global user.email "actions@github.com"
if ! git diff --quiet -- rules/asservs.txt; then
  git add rules/asservs.txt
  git commit -m "Auto-update: $(date -u +'%Y-%m-%d %H:%M UTC')"
  git push
  echo "✓ Changes committed"
else
  echo "✓ Nothing to commit, no rule changes"
fi


name: build surfing.txt

on:
  schedule:
    - cron: '40 18 * * *'  # everyday UTC 18:40 (BeiJing Time 02:40)
  workflow_dispatch:

permissions:
  contents: write
  
jobs:
  update-filter:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Run update script
        run: |
          set -e
          bash scripts/surfing_prepare.sh
          
          # Process asservs.txt to add || and ^
          if [ -f "rules/asservs.txt" ]; then
            sed -i 's/^/||/' rules/asservs.txt
            sed -i 's/$/^/' rules/asservs.txt
          fi

      - name: Commit changes
        run: |
          git config --global user.name "GitHub Actions"
          git config --global user.email "actions@github.com"
          git add rules/asservs.txt
          git commit -m "Update asservs.txt with formatting" || echo "No changes to commit"
          git push

      - name: Final cleanup
        if: always()
        run: |
          rm -rf rules/ scripts/ || true