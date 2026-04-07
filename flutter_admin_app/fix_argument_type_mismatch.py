import os
import re

def fix_argument_mismatches(project_root):
    analyze_file = os.path.join(project_root, 'current_analyze_utf8_v3.txt')
    if not os.path.exists(analyze_file): return

    with open(analyze_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    targets = {}
    for line in lines:
        # error - The argument type 'dynamic' can't be assigned to the parameter type 'int' - ...:21:51
        match = re.search(r'error - The argument type \'dynamic\' can\'t be assigned to the parameter type \'(.*?)\' - (lib[\\/].*?\.dart):(\d+):(\d+)', line)
        if match:
            target_type, rel_path, line_num, col_num = match.groups()
            # We only handle simple types: int, String, bool, num
            if target_type not in ['int', 'String', 'bool', 'num', 'double']: continue
            
            abs_path = os.path.join(project_root, rel_path.replace('\\', '/')).replace('\\', '/')
            if abs_path not in targets: targets[abs_path] = {}
            targets[abs_path][int(line_num)] = (target_type, int(col_num))

    for path, lines_dict in targets.items():
        if not os.path.exists(path): continue
        with open(path, 'r', encoding='utf-8', errors='ignore') as f:
            file_lines = f.readlines()

        changed = False
        for line_num, (target_type, col_num) in sorted(lines_dict.items(), reverse=True):
            idx = line_num - 1
            if idx >= len(file_lines): continue
            line = file_lines[idx]
            
            # This is tricky because we need to find the specific expression at col_num.
            # As a simple heuristic, if it's a map access or variable access, append 'as type'
            # But col_num starts from 1. 
            # We'll try to find the word before comma or closing paren.
            
            # Simple approach: if line has map access like data['field'], replace with data['field'] as type
            if "['" in line or '["' in line:
                # find the map access pattern
                # This regex is very simple, might need improvement.
                line = re.sub(r"(\w+\[['\"].*?['\"]\])", rf"(\1 as {target_type})", line)
                file_lines[idx] = line
                changed = True
            
        if changed:
            with open(path, 'w', encoding='utf-8') as f:
                f.writelines(file_lines)
            print(f"Refined argument types as {target_type} in {path}")

if __name__ == "__main__":
    fix_argument_mismatches('d:/MasterTreeApp/tree_app_monorepo/flutter_admin_app')
