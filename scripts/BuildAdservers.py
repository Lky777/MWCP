#!/usr/bin/env python3

import re
from pathlib import Path

def filter_domains_by_pattern(domains):
    """过滤域名：只保留允许的后缀，排除特定后缀"""
    allowed_pattern = re.compile(r'\.(com|cn|net|top|xyz)$')
    excluded_pattern = re.compile(r'\.(gov|edu|mil)\.cn$')
    
    return [
        domain for domain in domains
        if allowed_pattern.search(domain) and not excluded_pattern.search(domain)
    ]

def process_domains():
    """主处理函数"""
    source_dir = Path('source')
    rules_dir = Path('rules')
    rules_dir.mkdir(exist_ok=True)
    
    # 备份旧文件
    current_file = rules_dir / 'adservers.txt'
    old_file = rules_dir / 'adservers-old.txt'
    
    if current_file.exists():
        current_file.rename(old_file)
    
    # 读取白名单
    with open(source_dir / 'top100k-white.txt', 'r') as f:
        white_domains = {line.strip() for line in f if line.strip()}
    
    # 读取top100k
    filtered_domains = []
    with open(source_dir / 'top100k.txt', 'r') as f:
        for line in f:
            domain = line.strip()
            if domain and domain not in white_domains:
                filtered_domains.append(domain)
    
    # 查找top100k独有行
    final_domains = filter_domains_by_pattern(filtered_domains)
    
    # 写入新结果
    output_file = rules_dir / 'adservers.txt'
    with open(output_file, 'w') as f:
        f.write('\n'.join(final_domains))
    
    # 记录周新增域名
    if old_file.exists():
        with open(old_file, 'r') as f:
            old_domains = {line.strip() for line in f if line.strip()}
        
        new_domains = [d for d in final_domains if d not in old_domains]
        if new_domains:
            add_file = rules_dir / 'week-add.txt'
            with open(add_file, 'a') as f:
                f.write(f"\n! NEW - 更新\n")
                f.write('\n'.join(new_domains))
                f.write('\n')

if __name__ == "__main__":
    process_domains()
