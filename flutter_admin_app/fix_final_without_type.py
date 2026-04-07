import os
import re

def fix_final_vars(project_root):
    analyze_file = os.path.join(project_root, 'current_analyze_utf8_v5.txt')
    if not os.path.exists(analyze_file): return

    with open(analyze_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    targets = {}
    for line in lines:
        # error - Missing variable type for 'firstBlock' - ...:98:15
        match = re.search(r'error - Missing variable type for \'(.*?)\' - (lib[\\/].*?\.dart):(\d+):(\d+)', line)
        if match:
            var_name, rel_path, line_num, col_num = match.groups()
            abs_path = os.path.join(project_root, rel_path.replace('\\', '/')).replace('\\', '/')
            if abs_path not in targets: targets[abs_path] = {}
            targets[abs_path][int(line_num)] = (var_name, int(col_num))

    for path, lines_dict in targets.items():
        if not os.path.exists(path): continue
        with open(path, 'r', encoding='utf-8', errors='ignore') as f:
            file_lines = f.readlines()

        changed = False
        for line_num, (var_name, col_num) in sorted(lines_dict.items(), reverse=True):
            idx = line_num - 1
            if idx >= len(file_lines): continue
            line = file_lines[idx]
            
            # Pattern: final var_name = ...  -> final dynamic var_name = ...
            # or var var_name = ... -> dynamic var_name = ...
            orig_line = line
            line = re.sub(rf'\bfinal\s+{var_name}\b', f'final dynamic {var_name}', line)
            line = re.sub(rf'\bvar\s+{var_name}\b', f'dynamic {var_name}', line)
            
            if line != orig_line:
                file_lines[idx] = line
                changed = True

        if changed:
            with open(path, 'w', encoding='utf-8') as f:
                f.writelines(file_lines)
            print(f"Added explicit dynamic to final/var in {path}")

if __name__ == "__main__":
    fix_final_vars('d:/MasterTreeApp/tree_app_monorepo/flutter_admin_app')
