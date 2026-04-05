/// PDF 텍스트 가공 및 데이터 헬퍼 (Strategy: SRP & Maintenance)
/// BulkExtractionScreen의 복잡한 텍스트 변환 로직을 담당함.
class BulkTextUtils {
  /// Block 데이터에서 순수 텍스트를 추출하여 합침.
  static String getTextFromBlocks(dynamic blocks) {
    if (blocks == null) return '';
    if (blocks is! List) return blocks.toString();
    
    return blocks.map((b) {
      if (b is Map && b['type'] == 'text') {
        return b['content']?.toString() ?? '';
      } else if (b is String) {
        return b;
      }
      return '';
    }).where((s) => s.isNotEmpty).join('\n');
  }

  /// 탭이 선택되었을 때 에디터 필드에 채울 데이터 매핑.
  static Map<String, String> mapToEditorFields(Map<String, dynamic>? data) {
    if (data == null) {
      return <String, String>{
        'question': '',
        'answer': '',
        'hint': '',
        'wrong': '',
      };
    }

    return <String, String>{
      'question': getTextFromBlocks(data['question']),
      'answer': getTextFromBlocks(data['explanation']),
      'hint': getTextFromBlocks(data['hint']),
      'wrong': getTextFromBlocks(data['wrong_answer']),
    };
  }
}
