#!/usr/bin/env python3

from pathlib import Path
from datetime import datetime

def sort_white_list(white_list_file):
    with open(white_list_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    first_line = lines[0]
    rest_lines = lines[1:]

    rest_lines_sorted = sorted(rest_lines, key=lambda x: x.strip().lower())

    with open(white_list_file, 'w', encoding='utf-8') as f:
        f.write(first_line)
        f.writelines(rest_lines_sorted)

def find_unique_domains_robust(base_file, new_file, output_file):
    sort_white_list(base_file)
    
    output_path = Path(output_file)
    old_file = output_path.parent / "adservers-old.txt"
    if output_path.exists():
        output_path.rename(old_file)
    
    Path(output_file).parent.mkdir(parents=True, exist_ok=True)
    
    max_len = 100
    with open(base_file, 'r', encoding='utf-8') as f:
        base_domains = frozenset(
            domain[:max_len].strip()
            for domain in f 
            if domain.strip()
        )

    buffer_size = 1_000_000
    with open(new_file, 'r', encoding='utf-8') as f_new, \
         open(output_file, 'w', encoding='utf-8', buffering=buffer_size) as f_out:
        
        for line in f_new:
            domain = line[:max_len].strip()
            if domain and domain not in base_domains:
                f_out.write(f"{domain}\n")

def compare_and_append_new_domains():
    current_file = Path('rules') / 'adservers.txt'
    old_file = Path('rules') / 'adservers-old.txt'
    add_file = Path('rules') / 'week-add.txt'

    with open(old_file, 'r', encoding='utf-8') as f:
        old_domains = frozenset(
            domain.strip() for domain in f if domain.strip()
        )
 
    new_domains = []
    with open(current_file, 'r', encoding='utf-8') as f:
        for line in f:
            domain = line.strip()
            if domain and domain not in old_domains:
                new_domains.append(domain)
    
    if new_domains:
        current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with open(add_file, 'a', encoding='utf-8') as f:
            f.write(f"\n! NEW - {current_time}\n")
            for domain in new_domains:
                f.write(f"{domain}\n")

if __name__ == "__main__":
    base_dir = Path('source')
    find_unique_domains_robust(
        base_file=base_dir / 'top100k-white.txt',
        new_file=base_dir / 'top100k.txt',
        output_file=Path('rules') / 'adservers.txt'
    )
    
    compare_and_append_new_domains()