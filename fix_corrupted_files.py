
import os
import re

# Base paths
ROOT_DIR = r"d:\MasterTreeApp\tree_app_monorepo\flutter_admin_app\lib"

# Patterns to fix
PATTERNS = [
    # [1] URIs: replace Uri.parse('\/path') with Uri.parse('$baseUrl/path') or similar
    # Regex note: match '\/...' and replace with '$baseUrl/...'
    (re.compile(r"Uri\.parse\('\\\/([^']*)'\)"), r"Uri.parse('$baseUrl/\1')"),
    # Case for when the slash is missing or it's '\'
    (re.compile(r"Uri\.parse\('\\([^']?)'\)"), r"Uri.parse('$baseUrl/\1')"),
    
    # [2] Authorization token truncation: 'Bearer \'
    (re.compile(r"'Authorization': 'Bearer \\',"), r"'Authorization': 'Bearer $token',"),
    (re.compile(r"request\.headers\['Authorization'\] = 'Bearer \\';"), r"request.headers['Authorization'] = 'Bearer $token';"),
    
    # [3] Truncated Exception messages: '...: \'
    (re.compile(r"Exception\('([^']*): \\'\)"), r"Exception('\1: ${response.statusCode}')"),
    
    # [4] Hex color bug: 'FF\'
    (re.compile(r"hexStr = 'FF\\';"), r"hexStr = 'FF$hexStr';")
]

def fix_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    new_content = content
    
    # Determine the correct baseUrl variable
    if '_baseUrl' in content:
        url_var = '$_baseUrl'
    else:
        url_var = '$baseUrl'
        
    # [1] Fix URIs with the determined variable
    new_content = re.sub(r"Uri\.parse\('\\\/([^']*)'\)", f"Uri.parse('{url_var}/\\1')", new_content)
    # Special fix for cases like Uri.parse('\/quiz/\') or similar where id was lost
    # Note: Some IDs like $id or $userId might still be missing if they were replaced by \
    # We will manually check those or use a generic fix if possible.
    
    # [2] Fix Auth
    new_content = re.sub(r"'Authorization': 'Bearer \\',", r"'Authorization': 'Bearer $token',", new_content)
    new_content = re.sub(r"request\.headers\['Authorization'\] = 'Bearer \\';", r"request.headers['Authorization'] = 'Bearer $token';", new_content)
    
    # [3] Fix Exceptions
    new_content = re.sub(r"Exception\('([^']*): \\'\)", r"Exception('\1: ${response.statusCode}')", new_content)
    
    # [4] Hex Color
    new_content = re.sub(r"hexStr = 'FF\\';", r"hexStr = 'FF$hexStr';", new_content)

    # Specific fix for common broken paths with IDs (e.g. /trees/\)
    new_content = new_content.replace("Uri.parse('$baseUrl/')", "Uri.parse('$baseUrl/$id')")
    new_content = new_content.replace("Uri.parse('$_baseUrl/')", "Uri.parse('$_baseUrl/$id')")
    
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
                    print(f"Fixed: {file}")
                    fixed_count += 1
    
    print(f"\nTotal files fixed: {fixed_count}")

if __name__ == "__main__":
    main()
