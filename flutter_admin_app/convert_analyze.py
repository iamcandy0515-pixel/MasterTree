import sys

if len(sys.argv) < 3:
    print("Usage: python convert_analyze.py <input_file> <output_file>")
    sys.exit(1)

input_file = sys.argv[1]
output_file = sys.argv[2]

with open(input_file, 'rb') as f:
    content = f.read()
if content.startswith(b'\xff\xfe'):
    text = content.decode('utf-16')
else:
    text = content.decode('utf-8', errors='ignore')
with open(output_file, 'w', encoding='utf-8') as f:
    f.write(text)
