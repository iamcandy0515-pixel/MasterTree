import os
import re

def replace_in_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Regex for .withOpacity(value) -> .withValues(alpha: value)
    new_content = re.sub(r'\.withOpacity\s*\(\s*(.*?)\s*\)', r'.withValues(alpha: \1)', content)
    
    if content != new_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        return True
    return False

def main():
    base_dir = r'd:\MasterTreeApp\tree_app_monorepo\flutter_admin_app\lib'
    count = 0
    for root, dirs, files in os.walk(base_dir):
        for file in files:
            if file.endswith('.dart'):
                if replace_in_file(os.path.join(root, file)):
                    count += 1
                    print(f"Updated: {file}")
    print(f"Total files updated: {count}")

if __name__ == "__main__":
    main()
