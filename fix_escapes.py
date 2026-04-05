
import os
import re

ROOT_DIR = r"d:\MasterTreeApp\tree_app_monorepo\flutter_admin_app\lib"

def fix_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    new_content = content
    
    # [1] Remove unnecessary string escapes: \/ -> /
    # This happens often in URIs after my previous fixes
    new_content = new_content.replace(r"\/", r"/")
    
    # [2] Fix explicit-dynamic-map-literal in more places
    # Check for Map literals starting with { '...': ... }
    # but excluding those already having <String, dynamic>
    # Note: Regex is tricky here, but let's try common patterns in return or variable assignment
    # return { ... }  -> return <String, dynamic>{ ... }
    # jsonEncode({ ... }) -> jsonEncode(<String, dynamic>{ ... }) -- already done, but just in case
    
    # [3] Fix implicit casts for JSON access where type is obvious
    # e.g. json['key'] ?? ''  -> (json['key'] as String?) ?? ''
    # This is too risky to automate fully with regex alone.
    
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
                    print(f"Fixed unnecessary escapes: {file}")
                    fixed_count += 1
    
    print(f"\nTotal files fixed: {fixed_count}")

if __name__ == "__main__":
    main()
