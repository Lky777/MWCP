#!/usr/bin/env python3

from pathlib import Path
import sys

def sort_white_list(white_list_file):
    """
    对白名单文件进行排序，保留首行不变
    """
    try:
        # 读取文件
        with open(white_list_file, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        # 分离首行和其余行
        first_line = lines[0]
        rest_lines = lines[1:]
        
        # 去除空白行
        rest_lines = [line for line in rest_lines if line.strip()]
        
        # 按字母顺序排序（不区分大小写）
        rest_lines_sorted = sorted(rest_lines, key=lambda x: x.strip().lower())
        
        # 写回文件
        with open(white_list_file, 'w', encoding='utf-8') as f:
            f.write(first_line)
            # 保持原有的换行符格式
            for line in rest_lines_sorted:
                f.write(line)

def main():
    """
    主函数：直接指定文件路径
    """
    white_list_file = "source/top100k-white.txt"
    
    # 执行排序
    if sort_white_list(white_list_file):
        sys.exit(0)
    else:
        sys.exit(1)

if __name__ == "__main__":
    main()
