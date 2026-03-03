import os

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    new_lines = []
    i = 0
    changed = False
    while i < len(lines):
        line = lines[i]
        
        # Detect start of leading: IconButton(
        if 'leading: IconButton(' in line or 'leading: const BackButton()' in line or 'leading: const CloseButton()' in line:
            # We need to collect lines until we see the matching parenthesis/bracket or if it's on single line
            if 'leading: const' in line:
                i += 1
                changed = True
                continue
                
            buffer = []
            bracket_count = 0
            while i < len(lines):
                curr = lines[i]
                buffer.append(curr)
                bracket_count += curr.count('(') - curr.count(')')
                if bracket_count <= 0 and buffer[-1].strip().endswith(','): # assuming formats like ),
                    break
                elif bracket_count <= 0 and ')' in curr: # close button ends
                    # Check if next line is comma or trailing
                    if i + 1 < len(lines) and lines[i+1].strip() == ',':
                        i += 1
                        buffer.append(lines[i])
                    break
                i += 1
                
            block_str = ''.join(buffer)
            # if the block is a simple back button or close button that just pops
            if ('Navigator.pop' in block_str or 'Navigator.of(context).pop' in block_str or 'Get.back' in block_str) \
               and ('Icons.arrow_back_ios_new' in block_str or 'Icons.close' in block_str or 'Icons.arrow_back' in block_str):
                changed = True
            else:
                new_lines.extend(buffer)
        else:
            new_lines.append(line)
        i += 1

    if changed:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.writelines(new_lines)
        print(f"Removed leading boilerplate in: {filepath}")

for d in ['flutter_admin_app/lib', 'flutter_user_app/lib']:
    for root, _, files in os.walk(d):
        for file in files:
            if file.endswith('.dart'):
                process_file(os.path.join(root, file))
