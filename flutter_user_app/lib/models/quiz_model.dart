class QuizQuestion {
  final int id;
  final String imageUrl;
  final String description; // 정답 시 보여줄 설명
  final int correctAnswerIndex;
  final List<String> options;
  final Map<String, String> hints;

  QuizQuestion({
    required this.id,
    required this.imageUrl,
    required this.description,
    required this.correctAnswerIndex,
    required this.options,
    required this.hints,
  });

  String getHintText(String? hintKey) {
    if (hintKey == null) return '';
    final text = hints[hintKey];
    if (text == null || text.trim().isEmpty || text == '정보 없음') {
      return '해당 힌트 정보가 없습니다.';
    }
    return text;
  }
}

enum QuizRank { eagleEye, forestKeeper, sprout }

class QuizRankHelper {
  static const String sprout = '새싹';
  static const String forestKeeper = '숲의 파수꾼';
  static const String eagleEye = '매의 눈';

  static String getName(QuizRank rank) {
    switch (rank) {
      case QuizRank.eagleEye: return eagleEye;
      case QuizRank.forestKeeper: return forestKeeper;
      case QuizRank.sprout: return sprout;
    }
  }

  static QuizRank fromAverage(double avg) {
    if (avg <= 2.0) return QuizRank.eagleEye;
    if (avg <= 4.0) return QuizRank.forestKeeper;
    return QuizRank.sprout;
  }
}
