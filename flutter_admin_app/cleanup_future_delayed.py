import os
import re

def cleanup_future_delayed(project_root):
    for root, dirs, files in os.walk(project_root):
        for file in files:
            if file.endswith('.dart'):
                path = os.path.join(root, file)
                with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                
                # Replace multiple callbacks or syntax errors
                new_content = content.replace(', () {}, () {}', '')
                new_content = new_content.replace(', () {}', '')
                
                # Ensure it's Future<void>.delayed if needed, or just Future.delayed
                # Actually, Future<void>.delayed is preferred to avoid implicit dynamic.
                if new_content != content:
                    with open(path, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    print(f"Cleaned up Future.delayed in {path}")

if __name__ == "__main__":
    cleanup_future_delayed('d:/MasterTreeApp/tree_app_monorepo/flutter_admin_app/lib')
