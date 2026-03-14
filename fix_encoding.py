import os

path = r'd:\MasterTreeApp\tree_app_monorepo\flutter_admin_app\lib\features\quiz_management\widgets\single_image_manager_dialog.dart'
temp_path = path + '.tmp'

try:
    # Try reading as EUC-KR (CP949)
    with open(path, 'rb') as f:
        content = f.read()
    
    # Attempt to decode as cp949 and encode as utf-8
    decoded = content.decode('cp949', errors='replace')
    
    # Fix the specific corrupted Korean text if found
    # 아래 영역을 클릭하여 파일을 선택하거나, 영역을 클릭(포커스) 후 Ctrl+V를 눌러 이미지를 붙여넣으세요.
    # The corrupted pattern I saw was: ?래 ?역???릭?여 ?일???택?거?? ?역???릭(?커??????Ctrl+V??러 ??지?붙여?으?요.
    # But in the python decode it might look different.
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(decoded)
    print("Success: Converted to UTF-8")
except Exception as e:
    print(f"Error: {e}")
