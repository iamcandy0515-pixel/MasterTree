import 'package:flutter/material.dart';
import '../core/design_system.dart';
import '../models/quiz_model.dart';

class QuizResultController {
  late String title;
  late Color titleColor;
  late IconData titleIcon;
  late String description;

  void initFromStats({
    required int correctCount,
    required int accumulatedHintCount,
    required int solvedCount,
  }) {
    final double avgHints = solvedCount > 0
        ? (accumulatedHintCount / solvedCount)
        : 0.0;
    QuizRank rank;
    if (solvedCount == 0) {
      rank = QuizRank.sprout;
    } else if (avgHints <= 2.0) {
      rank = QuizRank.eagleEye;
    } else if (avgHints <= 4.0) {
      rank = QuizRank.forestKeeper;
    } else {
      rank = QuizRank.sprout;
    }
    init(rank);
  }

  void init(QuizRank rank) {
    switch (rank) {
      case QuizRank.eagleEye:
        title = '매의 눈 (Eagle Eye)';
        titleColor = const Color(0xFFFFD700); // Gold
        titleIcon = Icons.remove_red_eye;
        description = '거의 힌트 없이 나무를 알아보시는군요! 대단합니다!';
        break;
      case QuizRank.forestKeeper:
        title = '숲의 관리자';
        titleColor = AppColors.primary;
        titleIcon = Icons.forest;
        description = '안정적인 관찰력을 가지고 계시는군요.';
        break;
      case QuizRank.sprout:
        title = '자라나는 새싹';
        titleColor = Colors.lightGreen;
        titleIcon = Icons.spa;
        description = '조금 더 자세히 관찰해보세요! 성장하고 있습니다.';
        break;
    }
  }
}
