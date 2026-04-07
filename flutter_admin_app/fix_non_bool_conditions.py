import os
import re

def fix_non_bool_conditions(project_root):
    analyze_file = os.path.join(project_root, 'current_analyze_utf8_v5.txt')
    if not os.path.exists(analyze_file): return

    with open(analyze_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    targets = {}
    for line in lines:
        # error - Conditions must have a static type of 'bool' - ...:164:9
        match = re.search(r'error - Conditions must have a static type of \'bool\' - (lib[\\/].*?\.dart):(\d+):(\d+)', line)
        if match:
            rel_path, line_num, col_num = match.groups()
            abs_path = os.path.join(project_root, rel_path.replace('\\', '/')).replace('\\', '/')
            if abs_path not in targets: targets[abs_path] = []
            targets[abs_path].append((int(line_num), int(col_num)))

    for path, lines_list in targets.items():
        if not os.path.exists(path): continue
        with open(path, 'r', encoding='utf-8', errors='ignore') as f:
            file_lines = f.readlines()

        changed = False
        # Process lines from bottom to top to avoid offset issues
        for line_num, col_num in sorted(lines_list, key=lambda x: x[0], reverse=True):
            idx = line_num - 1
            if idx >= len(file_lines): continue
            line = file_lines[idx]
            
            # Find the condition inside if(...)
            # This is complex with regex, let's try simple replacements for common patterns
            # Pattern 1: if (data['field']) -> if (data['field'] == true)
            # Pattern 2: if (!data['field']) -> if (data['field'] != true)
            # Pattern 3: if (obj.field) where field is dynamic
            
            orig_line = line
            # Pattern 1: if (data['field']?.isNotEmpty ?? false) -> if ((data['field'] as List?)?.isNotEmpty ?? false)
            line = re.sub(r"if \((.*?\[['\"].*?['\"]\])\?\.isNotEmpty ?? false\)", r"if ((\1 as List?)?.isNotEmpty ?? false)", line)
            
            # Pattern 2: if (data['field']) -> if (data['field'] == true)
            line = re.sub(r"if \((.*?\[['\"].*?['\"]\])\)", r"if (\1 == true)", line)
            
            # Pattern 3: if (!data['field']) -> if (data['field'] != true)
            line = re.sub(r"if \(!(.*?\[['\"].*?['\"]\])\)", r"if (\1 != true)", line)
            
            if line != orig_line:
                file_lines[idx] = line
                changed = True

        if changed:
            with open(path, 'w', encoding='utf-8') as f:
                f.writelines(file_lines)
            print(f"Fixed non-bool conditions in {path}")

if __name__ == "__main__":
    fix_non_bool_conditions('d:/MasterTreeApp/tree_app_monorepo/flutter_admin_app')
