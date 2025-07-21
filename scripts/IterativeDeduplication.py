#!/usr/bin/env python3

def deduplicate_contained_lines(lines):
    cleaned_lines = [line.strip() for line in lines if line.strip()]
    cleaned_lines.sort(key=len)
    
    result = []
    seen_lower = set()
    
    for line in cleaned_lines:
        line_lower = line.lower()
        
        is_contained = any(line_lower in existing for existing in seen_lower)
        containing = [existing for existing in seen_lower if existing in line_lower]
        
        for existing in containing:
            index = next(i for i, x in enumerate(result) if x.lower() == existing)
            result.pop(index)
            seen_lower.remove(existing)
        
        if not is_contained and line_lower not in seen_lower:
            result.append(line)
            seen_lower.add(line_lower)
    
    return result

def process_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    deduplicated_lines = deduplicate_contained_lines(lines)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(deduplicated_lines))

if __name__ == "__main__":
    process_file('rules/matrix.txt')
