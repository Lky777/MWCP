#!/usr/bin/env python3

def update_dragon(dragon_path, add_path, del_path):
    with open(del_path) as f:
        del_lines = {line.rstrip() for line in f}  # 读取要删除的行

    with open(dragon_path) as f1, open(add_path) as f2:
        lines = f1.readlines() + f2.readlines()  # 合并文件

    # 过滤+去重+排序
    lines = sorted({line.rstrip(): line for line in lines 
                   if line.rstrip() not in del_lines}.values(),
                   key=lambda x: x.rstrip().lower())

    with open(dragon_path, 'w', newline='\n') as f:
        f.writelines(lines)

if __name__ == '__main__':
    import sys
    update_dragon(*sys.argv[1:4])
