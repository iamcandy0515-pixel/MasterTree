import 'package:flutter_admin_app/features/quiz_management/repositories/quiz_drive_repository.dart';

class QuizExtractionService {
  final QuizDriveRepository _quizRepo = QuizDriveRepository();

  /// PDF에서 퀴즈를 추출하고 형식에 맞게 매핑
  Future<Map<int, Map<String, dynamic>>> extractChunk({
    required String fileId,
    required String subject,
    required int year,
    required int round,
    required int start,
    required int end,
  }) async {
    final batchData = await _quizRepo.extractBatch(
      fileId: fileId,
      startNumber: start,
      endNumber: end,
      subject: subject,
      year: year,
      round: round,
    );

    final Map<int, Map<String, dynamic>> results = {};
    for (var item in batchData) {
      final qNumRaw = item['question_number'];
      final qNum = qNumRaw is int
          ? qNumRaw
          : int.tryParse(qNumRaw?.toString() ?? '') ?? 0;
      if (qNum <= 0) continue;

      results[qNum] = _mapExtractedItem(item, qNum);
    }
    return results;
  }

  /// 추출된 개별 아이템을 내부 데이터 구조로 변환
  Map<String, dynamic> _mapExtractedItem(Map<String, dynamic> item, int qNum) {
    String explanation =
        (item['explanation_blocks'] ?? item['explanation'] ?? '').toString();
    explanation = explanation
        .split('\n')
        .where((line) => !line.contains('해당사항 없음') && !line.contains('필요 없음'))
        .join('\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();

    final Map<String, dynamic> mappedItem = {
      'question_number': qNum,
      'question': item['content_blocks'] ?? item['question'] ?? [],
      'explanation': item['explanation_blocks'] ?? item['explanation'] ?? [],
      'hint': _processHintToBlocks(item),
      'correct_option_index': _toInt(item['correct_option_index']),
      'options': item['options'] ?? [],
    };

    _ensureBlocks(mappedItem, 'question', item['question']);
    _ensureBlocks(mappedItem, 'explanation', explanation);
    _ensureBlocks(mappedItem, 'hint', '');

    // 오답 대표값 설정 및 블록화
    final options = mappedItem['options'] as List;
    final cIdx = mappedItem['correct_option_index'] as int;
    if (options.length >= 2) {
      final wIdx = 1 - cIdx;
      if (wIdx >= 0 && wIdx < options.length) {
        mappedItem['wrong_answer'] = options[wIdx].toString();
      }
    }
    _ensureBlocks(mappedItem, 'wrong_answer', '');

    return mappedItem;
  }

  dynamic _processHintToBlocks(Map<String, dynamic> item) {
    if (item['hint_blocks'] is List) {
      return item['hint_blocks'];
    }
    final hint = (item['hint'] ?? '').toString();
    if (hint.isEmpty) return [];
    return [
      {'type': 'text', 'content': hint}
    ];
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  void _ensureBlocks(
    Map<String, dynamic> item,
    String field,
    dynamic fallback,
  ) {
    if (item[field] is String) {
      item[field] = [
        {'type': 'text', 'content': item[field]},
      ];
    } else if (item[field] is! List || (item[field] as List).isEmpty) {
      item[field] = [
        {'type': 'text', 'content': fallback?.toString() ?? ''},
      ];
    }
  }

  /// DB에 일괄 저장할 데이터 준비
  List<Map<String, dynamic>> prepareBatchForDatabase(
    List<Map<String, dynamic>> quizzes,
  ) {
    return quizzes.map((quiz) {
      final qNum = quiz['question_number'];

      return <String, dynamic>{
        'question_number': qNum,
        'content_blocks': quiz['question'] ?? [],
        'explanation_blocks': quiz['explanation'] ?? [],
        'correct_option_index': quiz['correct_option_index'],
        'options': quiz['options'],
        'status': 'active',
        'hint_blocks': quiz['hint'] ?? [],
      };
    }).toList();
  }
}
