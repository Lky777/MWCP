#!/usr/bin/env python3
from pathlib import Path

def find_unique_domains_robust(base_file, new_file, output_file):

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

if __name__ == "__main__":
    base_dir = Path('source')
    find_unique_domains_robust(
        base_file=base_dir / 'top100k250623.txt',
        new_file=base_dir / 'top100k.txt',
        output_file=Path('rules') / 'adservers.txt'
    )
