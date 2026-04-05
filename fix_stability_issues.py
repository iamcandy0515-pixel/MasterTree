
import os
import re

ROOT_DIR = r"d:\MasterTreeApp\tree_app_monorepo\flutter_admin_app\lib"

def fix_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    new_content = content
    
    # [1] Fix Truncated Error Messages: '실패: '; -> '실패: $e';
    # This specifically looks for lines ending with ': '; and tries to find 'catch (e) {' context
    # Regex: catch (e) { ... _errorMessage = '...: ';
    def fix_error_strings(m):
        prefix = m.group(1)
        # Check if we should use $e or something else. Most use 'catch (e)'
        return f"{prefix}: $e';"
    
    new_content = re.sub(r"(_errorMessage = '[^']*): ';", fix_error_strings, new_content)
    new_content = re.sub(r"(throw Exception\('[^']*): ';", fix_error_strings, new_content)

    # [2] Fix Implicit Dynamic Map Literals in jsonEncode
    # jsonEncode({ ... }) -> jsonEncode(<String, dynamic>{ ... })
    new_content = re.sub(r"jsonEncode\(\{", r"jsonEncode(<String, dynamic>{", new_content)
    # Also for common map literals in repositories
    new_content = re.sub(r"return \{", r"return <String, dynamic>{", new_content)
    new_content = re.sub(r"headers: \{", r"headers: <String, String>{", new_content)
    
    # [3] Specific regression: 'Authorization': 'Bearer $token'
    # In some places it was 'Bearer $token' but the $token was lost or messed up.
    # We already fixed 'Bearer \' in previous script.
    
    # [4] Fix 'FF\' in hex colors
    new_content = re.sub(r"'FF\\'", r"'FF$hexStr'", new_content)

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
                    print(f"Fixed: {os.path.relpath(abspath, ROOT_DIR)}")
                    fixed_count += 1
    
    print(f"\nTotal files fixed: {fixed_count}")

if __name__ == "__main__":
    main()
