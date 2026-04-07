import os
import re

def fix_json_decode(project_root):
    # current_analyze_utf8_v2.txt 
    analyze_file = os.path.join(project_root, 'current_analyze_utf8_v2.txt')
    if not os.path.exists(analyze_file):
        return

    with open(analyze_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    targets = {}
    for line in lines:
        match = re.search(r'error - Missing variable type for \'(.*?)\' - (lib[\\/].*?\.dart):(\d+):(\d+)', line)
        if match:
            var_name, rel_path, line_num, col_num = match.groups()
            rel_path = rel_path.replace('\\', '/')
            abs_path = os.path.join(project_root, rel_path).replace('\\', '/')
            if abs_path not in targets:
                targets[abs_path] = {}
            targets[abs_path][int(line_num)] = var_name

    for path, lines_dict in targets.items():
        if not os.path.exists(path): continue
        with open(path, 'r', encoding='utf-8', errors='ignore') as f:
            file_lines = f.readlines()

        changed = False
        for line_num, var_name in sorted(lines_dict.items(), reverse=True):
            idx = line_num - 1
            if idx >= len(file_lines): continue
            line = file_lines[idx]
            
            # Pattern: final jsonResponse = jsonDecode(...);
            if f'final {var_name} = ' in line and 'jsonDecode(' in line:
                file_lines[idx] = line.replace(f'final {var_name} = ', f'final Map<String, dynamic> {var_name} = ')
                # Ensure the RHS is also casted to avoid further issues if needed, 
                # but often 'as Map<String, dynamic>' is needed at the end.
                if 'as Map<String, dynamic>' not in file_lines[idx] and ');' in file_lines[idx]:
                     file_lines[idx] = file_lines[idx].replace(');', ') as Map<String, dynamic>;')
                changed = True
            
            # Pattern: final data = ...;
            elif f'final {var_name} = ' in line:
                # If it looks like a Map access
                if "['" in line or '["' in line:
                    file_lines[idx] = line.replace(f'final {var_name} = ', f'final dynamic {var_name} = ')
                    changed = True

        if changed:
            with open(path, 'w', encoding='utf-8') as f:
                f.writelines(file_lines)
            print(f"Fixed JSON/Variable types in {path}")

if __name__ == "__main__":
    fix_json_decode('d:/MasterTreeApp/tree_app_monorepo/flutter_admin_app')
