
import os
import re

ROOT_DIR = r"d:\MasterTreeApp\tree_app_monorepo\flutter_admin_app\lib"

def fix_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    new_content = content
    
    # [1] Fix URI corruption in typical REST templates: /users/\ or /users/id/\
    # Some IDs were completely lost and replaced by \
    # We'll use $id if it looks like there's an id variable available in the scope
    
    has_id = 'String id' in content or 'dynamic id' in content or 'int id' in content
    id_var = '$id' if has_id else '$id' # Defaulting to $id
    
    # Specific fix for UserRepository cases
    if 'class UserRepository' in content:
        new_content = new_content.replace("'page=\&limit=\\';", "'page=$page&limit=$limit';")
        new_content = new_content.replace("Uri.parse('$_baseUrl/users?\\')", "Uri.parse('$_baseUrl/users?status=$status');")
        new_content = new_content.replace("/users/\\/status", "/users/$id/status")
        new_content = new_content.replace("/users/\\", "/users/$id")
    
    # Generic fix for any Uri.parse ending or containing \
    new_content = re.sub(r"Uri\.parse\('([^']*)(\\)'\)", r"Uri.parse('\1$id')", new_content)
    
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        return True
    return False

def main():
    fixed_count = 0
    for root, dirs, files in os.walk(ROOT_DIR):
        for file in files:
            if file.endswith('.dart'):
                abspath = os.path.join(root, file)
                if fix_file(abspath):
                    print(f"Fixed URL patterns: {file}")
                    fixed_count += 1
    
    print(f"\nTotal files fixed: {fixed_count}")

if __name__ == "__main__":
    main()
