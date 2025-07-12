#!/usr/bin/env python3

def deduplicate_contained_lines(lines):
    """
    删除包含关系的行（不区分大小写），保留最短行
    :param lines: 行列表
    :return: 去重后的行列表
    """
    result = []
    seen_lower = set()  # 存储小写版本用于比较
    
    for line in lines:
        original_line = line.strip()
        if not original_line:  # 跳过空行
            continue
            
        line_lower = original_line.lower()
        to_remove = []
        should_add = True
        
        # 检查与已存在行的关系
        for existing in result:
            existing_lower = existing.lower()
            
            if line_lower == existing_lower:
                should_add = False
                break
            elif line_lower in existing_lower:
                to_remove.append(existing)
            elif existing_lower in line_lower:
                should_add = False
                break
        
        # 移除被当前行包含的长行
        for item in to_remove:
            result.remove(item)
            seen_lower.remove(item.lower())
        
        if should_add and line_lower not in seen_lower:
            result.append(original_line)
            seen_lower.add(line_lower)
    
    return result

def process_file(file_path):
    """
    处理文件去重（直接覆盖原文件）
    :param file_path: 要处理的文件路径
    """
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    deduplicated_lines = deduplicate_contained_lines(lines)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(deduplicated_lines))

if __name__ == "__main__":
    # 使用示例
    process_file('rules/matrix.txt')