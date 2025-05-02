import time

def is_redundant(shorter, longer):
    """判断 shorter 是否被 longer 包含（忽略空格和大小写）"""
    s = shorter.strip().lower()
    l = longer.strip().lower()
    return s != l and s in l

def dedup_rules(lines):
    print(f"[INFO] 原始规则数: {len(lines)}")
    lines = [line.strip().lower() for line in lines if line.strip()]  # 转换为小写并去除空格
    lines.sort(key=len)  # 优先保留短规则
    keep = []
    kept_set = set()  # 用集合来加速查找重复项

    for i, line in enumerate(lines):
        # 如果当前规则是已存在规则的子集（忽略大小写），则跳过
        if any(is_redundant(line, kept) for kept in kept_set):
            continue
        keep.append(line)
        kept_set.add(line)  # 添加到集合中

        if i % 1000 == 0 and i > 0:
            print(f"[INFO] 已处理 {i} 条规则，当前保留 {len(keep)} 条")

    print(f"[INFO] 去重后规则数: {len(keep)}")
    return keep

def process_file(input_file='rules/combined_rules.txt', output_file='rules/dedup_rules.txt'):
    start = time.time()
    print("[INFO] 开始规则去重处理...")

    with open(input_file, 'r', encoding='utf-8') as f:
        raw_lines = f.readlines()

    deduped = dedup_rules(raw_lines)

    with open(output_file, 'w', encoding='utf-8') as f:
        for line in deduped:
            f.write(line + '\n')

    print(f"[INFO] 去重完成，耗时 {time.time() - start:.2f} 秒")

if __name__ == "__main__":
    process_file()
