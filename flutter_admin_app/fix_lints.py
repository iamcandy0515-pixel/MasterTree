import os
import re

def fix_file(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
    except Exception as e:
        print(f"Error reading {filepath}: {e}")
        return False
    
    # 1. replace withOpacity(x) with withValues(alpha: x)
    new_content = re.sub(r'\.withOpacity\((.*?)\)', r'.withValues(alpha: \1)', content)
    
    # 2. replace print( with debugPrint(
    new_content = re.sub(r'(?<!\.)print\(', 'debugPrint(', new_content)

    if content != new_content:
        try:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            return True
        except Exception as e:
            print(f"Error writing {filepath}: {e}")
    return False

root = 'd:/MasterTreeApp/tree_app_monorepo/flutter_admin_app/lib'
fixed_count = 0
for r, dirs, files in os.walk(root):
    for f in files:
        if f.endswith('.dart'):
            if fix_file(os.path.join(r, f)):
                fixed_count += 1

print(f"Fixed {fixed_count} files.")
