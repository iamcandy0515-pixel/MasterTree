import os
import re

def fix_implicit_dynamic(project_root):
    # current_analyze_utf8.txt 는 'flutter analyze'의 실행 결과 파일
    analyze_file = os.path.join(project_root, 'current_analyze_utf8.txt')
    if not os.path.exists(analyze_file):
        print(f"Analyze file not found at {analyze_file}!")
        return

    try:
        with open(analyze_file, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except Exception as e:
        print(f"Error reading analyze file: {e}")
        return

    # File -> {Line -> Types of Errors}
    targets = {}

    for line in lines:
        # 매칭 패턴 예시: error - Missing parameter type for 'block' - lib\core...dart:26:29 - implicit_dynamic_parameter
        match = re.search(r'error - (.*?) - (lib[\\/].*?\.dart):(\d+):(\d+) - (.*)', line)
        if match:
            msg, rel_path, line_num, col_num, error_code = match.groups()
            # 윈도우 경로인 경우 역슬래시 처리
            rel_path = rel_path.replace('\\', '/')
            abs_path = os.path.join(project_root, rel_path).replace('\\', '/')
            
            if abs_path not in targets:
                targets[abs_path] = {}
            
            l_num = int(line_num)
            if l_num not in targets[abs_path]:
                targets[abs_path][l_num] = []
            
            targets[abs_path][l_num].append({
                'col': int(col_num),
                'code': error_code,
                'msg': msg
            })

    print(f"Parsed {len(targets)} files with errors.")

    fixed_files = 0
    for path, lines_dict in targets.items():
        if not os.path.exists(path):
            # print(f"Skipping non-existent file: {path}")
            continue
        
        try:
            with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                file_lines = f.readlines()
        except:
            continue

        changed = False
        # 정렬: 줄 번호가 뒤쪽인 것부터 처리 (단, 여기서는 줄 추가가 없으므로 정방향도 무난하나 전통적으로 역순 권장)
        for line_num in sorted(lines_dict.keys(), reverse=True):
            idx = line_num - 1
            if idx >= len(file_lines): continue
            
            orig_line = file_lines[idx]
            new_line = orig_line
            
            # (1) MaterialPageRoute -> MaterialPageRoute<dynamic>
            if 'MaterialPageRoute(' in new_line and 'MaterialPageRoute<' not in new_line:
                new_line = new_line.replace('MaterialPageRoute(', 'MaterialPageRoute<dynamic>(')
            
            # (2) Navigator.push -> Navigator.push<dynamic>
            if 'Navigator.push(' in new_line and 'Navigator.push<' not in new_line:
                new_line = new_line.replace('Navigator.push(', 'Navigator.push<dynamic>(')
            
            # (3) Navigator.pushReplacement -> <dynamic, dynamic>
            # Use regex to replace pushReplacement<...> (one arg) with <dynamic, dynamic>
            if 'pushReplacement' in new_line:
                new_line = re.sub(r'pushReplacement<(void|dynamic)>', r'pushReplacement<dynamic, dynamic>', new_line)
                if 'pushReplacement(' in new_line and 'pushReplacement<' not in new_line:
                    new_line = new_line.replace('pushReplacement(', 'pushReplacement<dynamic, dynamic>(')

            # (4) Navigator.pushAndRemoveUntil -> <dynamic>
            if 'pushAndRemoveUntil' in new_line:
                if 'pushAndRemoveUntil(' in new_line and 'pushAndRemoveUntil<' not in new_line:
                    new_line = new_line.replace('pushAndRemoveUntil(', 'pushAndRemoveUntil<dynamic>(')
                elif 'pushAndRemoveUntil<void>' in new_line:
                     new_line = new_line.replace('pushAndRemoveUntil<void>', 'pushAndRemoveUntil<dynamic>')
                elif 'pushAndRemoveUntil<dynamic>' in new_line:
                     pass # already ok
            
            # (5) Navigator.push / MaterialPageRoute / showDialog -> <dynamic>
            for method in ['Navigator.push', 'MaterialPageRoute', 'showDialog']:
                if method in new_line:
                    # Replace <void> (if any)
                    new_line = new_line.replace(f'{method}<void>', f'{method}<dynamic>')
                    # Add <dynamic> if missing
                    if f'{method}(' in new_line and f'{method}<' not in new_line:
                        new_line = new_line.replace(f'{method}(', f'{method}<dynamic>(')

            # (5) showDialog -> showDialog<dynamic>
            if 'showDialog(' in new_line and 'showDialog<' not in new_line:
                new_line = new_line.replace('showDialog(', 'showDialog<dynamic>(')

            # (6) List literal: [] -> <dynamic>[] (implicit_dynamic_list_literal 해결)
            # Find '[' not preceded by '<'
            if '[' in new_line and (new_line.find('[') == 0 or '<' not in new_line[new_line.find('[')-1]) and not new_line.strip().startswith('//'):
                 # Simple heuristic: space or bracket or paren before [
                 new_line = re.sub(r'(^|[\s\(\[\{,])\[\]', r'\1<dynamic>[]', new_line)
                 new_line = re.sub(r'(^|[\s\(\[\{,])\[\s+\]', r'\1<dynamic>[]', new_line)

            # (7) Map literal: {} -> <String, dynamic>{} (implicit_dynamic_map_literal 해결)
            if '{' in new_line and (new_line.find('{') == 0 or '<' not in new_line[new_line.find('{')-1]) and not new_line.strip().startswith('//'):
                 new_line = re.sub(r'(^|[\s\(\[\{,])\{\}', r'\1<String, dynamic>{}', new_line)
                 new_line = re.sub(r'(^|[\s\(\[\{,])\{\s+\}', r'\1<String, dynamic>{}', new_line)
            
            # (8) Supabase select method: .select() -> .select<PostgrestList>()
            if '.select(' in new_line and '<' not in new_line.split('.select(')[0][-1:]:
                new_line = new_line.replace('.select(', '.select<PostgrestList>(')
            
            # (9) Future delayed: Future.delayed() -> Future<void>.delayed()
            if 'Future.delayed(' in new_line and '<' not in new_line.split('Future.delayed(')[0][-1:]:
                new_line = new_line.replace('Future.delayed(', 'Future<void>.delayed(')
            # Fix previous mistake if any
            if 'Future.delayed<void>(' in new_line:
                new_line = new_line.replace('Future.delayed<void>(', 'Future<void>.delayed(')

            if new_line != orig_line:
                file_lines[idx] = new_line
                changed = True

        if changed:
            try:
                with open(path, 'w', encoding='utf-8') as f:
                    f.writelines(file_lines)
                fixed_files += 1
            except:
                pass

    print(f"Successfully processed {fixed_files} files.")

if __name__ == "__main__":
    fix_implicit_dynamic('d:/MasterTreeApp/tree_app_monorepo/flutter_admin_app')
