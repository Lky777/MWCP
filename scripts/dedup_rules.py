# 对规则递归去重
def is_superstring(line1, line2):
    """判断 line2 是否是 line1 的超集（忽略大小写和首尾空格）"""
    l1 = line1.strip().lower()
    l2 = line2.strip().lower()
    return l1 != l2 and l1 in l2

def recursive_dedup(lines):
    # 去除空行并去掉每行首尾空格
    lines = [line.strip() for line in lines if line.strip()]
    
    changed = True
    while changed:
        changed = False
        keep_flags = [True] * len(lines)

        for i, line in enumerate(lines):
            if not keep_flags[i]:
                continue
            for j, other_line in enumerate(lines):
                if i == j or not keep_flags[j]:
                    continue
                if is_superstring(line, other_line):
                    if "@@" not in other_line and "～" not in other_line:
                        keep_flags[j] = False
                        changed = True

        lines = [line for i, line in enumerate(lines) if keep_flags[i]]

    return lines

def process_file(input_file='rules/combined_rules.txt', output_file='rules/dedup_rules.txt'):
    with open(input_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    deduped_lines = recursive_dedup(lines)

    with open(output_file, 'w', encoding='utf-8') as f:
        for line in deduped_lines:
            f.write(line.strip() + '\n')

# 执行
process_file()
