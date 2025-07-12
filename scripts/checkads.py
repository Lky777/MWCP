#!/usr/bin/env python3
import os
def find_unique_lines(file1_path, file2_path, output_path):
    # 1. 读取 file1 的所有行（用集合存储，O(1) 查找）
    with open(file1_path, 'r', encoding='utf-8') as file1:
        file1_lines = {line.strip() for line in file1 if line.strip()}

    # 2. 逐行检查 file2 的独有行（避免全量加载）
    unique_lines = []
    with open(file2_path, 'r', encoding='utf-8') as file2:
        for line in file2:
            stripped_line = line.strip()
            if stripped_line and stripped_line not in file1_lines:
                unique_lines.append(stripped_line)

    # 3. 直接覆盖写入到输出文件
    with open(output_path, 'w', encoding='utf-8') as output_file:
        output_file.write('\n'.join(unique_lines) + '\n')

# 文件路径
file1_path = 'source/top100k250623.csv'
file2_path = 'source/top100k.csv'
output_path = 'rules/adservers.txt'

# 确保输出目录存在
os.makedirs(os.path.dirname(output_path), exist_ok=True)

# 执行比较
find_unique_lines(file1_path, file2_path, output_path)
