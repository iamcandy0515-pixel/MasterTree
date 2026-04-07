class ExamDataUtility {
  static String extractQuestionText(Map<String, dynamic> quiz) {
    String qText = '문제 내용 없음';
    try {
      final blocks = quiz['content_blocks'] as List<dynamic>;
      if (blocks.isNotEmpty) {
        qText = blocks[0]['content'] as String;
      }
    } catch (_) {}

    final Object? qNum = quiz['question_number'];
    if (qNum != null) {
      final String qNumStr = qNum.toString().padLeft(2, '0');
      if (qText.startsWith(qNumStr)) {
        qText = qText.substring(qNumStr.length).trim();
      }
      return '$qNum번. $qText';
    }
    return qText;
  }
}
