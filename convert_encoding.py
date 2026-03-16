import sys

def convert(filename):
    try:
        with open(filename, 'rb') as f:
            content = f.read()
        # PowerShell redirection typically uses utf-16le
        text = content.decode('utf-16le')
        with open(filename, 'w', encoding='utf-8') as f:
            f.write(text)
        print(f"Converted {filename} to UTF-8")
    except Exception as e:
        print(f"Error converting {filename}: {e}")

if __name__ == "__main__":
    convert('user_analyze.txt')
    convert('admin_analyze.txt')
