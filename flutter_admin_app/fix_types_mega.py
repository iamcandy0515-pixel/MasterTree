import os
import re

def fix_types_mega(project_root):
    # We'll use v8 result as input
    analyze_file = os.path.join(project_root, 'current_analyze_utf8_final.txt')
    if not os.path.exists(analyze_file): return

    with open(analyze_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    type_map = {
        'Map<String, dynamic>': 'Map<String, dynamic>',
        'Iterable<dynamic>': 'Iterable<dynamic>',
        'List<dynamic>': 'List<dynamic>',
        'int': 'int',
        'String': 'String',
        'bool': 'bool',
        'num': 'num',
        'double': 'double',
        'Uint8List': 'Uint8List',
        'XFile': 'dynamic'
    }

    targets = {}
    
    # regex to find the type and path/line/col from different error formats
    def parse_error(line):
        # Format 1: The argument type 'dynamic' can't be assigned to... 'Type'
        m1 = re.search(r'[\"\']dynamic[\"\'] (can\'t be assigned to.*?|isn\'t a.*?) [\"\'](.*?)[\"\'] - (lib[\\/].*?\.dart):(\d+):(\d+)', line)
        if m1:
            return ("CAST", m1.group(2), m1.group(3), int(m1.group(4)), int(m1.group(5)))
        
        # Format 2: Missing type arguments for generic type 'Future<dynamic>'
        m2 = re.search(r'Missing type arguments for generic type [\"\']Future<dynamic>[\"\'] - (lib[\\/].*?\.dart):(\d+):(\d+)', line)
        if m2:
            return ("FUTURE_DELAYED", "", m2.group(1), int(m2.group(2)), int(m2.group(3)))
            
        # Format 3: Missing parameter type for 'param'
        m3 = re.search(r'Missing parameter type for [\"\'](.*?)[\"\'] - (lib[\\/].*?\.dart):(\d+):(\d+)', line)
        if m3:
            return ("PARAM", m3.group(1), m3.group(2), int(m3.group(3)), int(m3.group(4)))
            
        return None

    for line in lines:
        parsed = parse_error(line)
        if parsed:
            op, val, rel_path, line_num, col_num = parsed
            abs_path = os.path.join(project_root, rel_path.replace('\\', '/')).replace('\\', '/')
            if abs_path not in targets: targets[abs_path] = {}
            targets[abs_path][line_num] = (op, val)

    processed_count = 0
    for path, lines_dict in targets.items():
        if not os.path.exists(path): continue
        with open(path, 'r', encoding='utf-8', errors='ignore') as f:
            file_lines = f.readlines()

        changed = False
        for line_num in sorted(lines_dict.keys(), reverse=True):
            idx = line_num - 1
            if idx >= len(file_lines): continue
            orig_line = file_lines[idx]
            op, val = lines_dict[line_num]

            if op == "FUTURE_DELAYED":
                if 'Future.delayed(' in orig_line:
                    file_lines[idx] = orig_line.replace('Future.delayed(', 'Future<void>.delayed(')
                    if not ', ()' in file_lines[idx]:
                        file_lines[idx] = file_lines[idx].replace('))', '), () {})').replace(');', ', () {});')
                    changed = True
            
            elif op == "PARAM":
                param = val
                patterns = [
                    (f'({param})', f'(dynamic {param})'),
                    (f' {param},', f' dynamic {param},'),
                    (f'({param},', f'(dynamic {param},'),
                    (f', {param},', f', dynamic {param},'),
                    (f', {param})', f', dynamic {param})'),
                ]
                for p, r in patterns:
                    if p in file_lines[idx]:
                        file_lines[idx] = file_lines[idx].replace(p, r)
                        changed = True
                        break

            elif op == "CAST":
                target_type = type_map.get(val, val)
                # Avoid circular casting or basic types that shouldn't be casted if too complex
                # Target common patterns
                matches = list(re.finditer(r'(\w+\[[^\]]+\]|\w+\.\w+|\(\w+\[[^\]]+\]\))', file_lines[idx]))
                if matches:
                    # Replace the first one found that's not already casted
                    for m in matches:
                        expr = m.group(1)
                        if f"{expr} as" not in file_lines[idx]:
                            file_lines[idx] = file_lines[idx].replace(expr, f"({expr} as {target_type})")
                            changed = True
                            break

        if changed:
            with open(path, 'w', encoding='utf-8') as f:
                f.writelines(file_lines)
            processed_count += 1
            print(f"Applied fixes (mega) to {path}")

    print(f"Total files fixed (mega): {processed_count}")

if __name__ == "__main__":
    fix_types_mega('d:/MasterTreeApp/tree_app_monorepo/flutter_admin_app')
