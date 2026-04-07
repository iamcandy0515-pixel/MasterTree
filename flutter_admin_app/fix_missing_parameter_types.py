import os
import re

def fix_missing_types(project_root):
    analyze_file = os.path.join(project_root, 'current_analyze_utf8_v3.txt')
    if not os.path.exists(analyze_file): return

    with open(analyze_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    targets = {}
    for line in lines:
        # error - Missing parameter type for 'block' - lib\core\widgets\content_block_renderer.dart:26:29
        match = re.search(r'error - Missing parameter type for \'(.*?)\' - (lib[\\/].*?\.dart):(\d+):(\d+)', line)
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
            
            # Simple replacement for common closure patterns
            # e.g. .map((e) =>   -> .map((dynamic e) =>
            patterns = [
                (f'({var_name}) =>', f'(dynamic {var_name}) =>'),
                (f'({var_name}) {{', f'(dynamic {var_name}) {{'),
                (f' {var_name}) =>', f' dynamic {var_name}) =>'), # for (item) => ...
            ]
            
            for old, new in patterns:
                if old in line:
                    file_lines[idx] = line.replace(old, new)
                    changed = True
                    break

        if changed:
            with open(path, 'w', encoding='utf-8') as f:
                f.writelines(file_lines)
            print(f"Fixed missing parameter types in {path}")

if __name__ == "__main__":
    fix_missing_types('d:/MasterTreeApp/tree_app_monorepo/flutter_admin_app')
