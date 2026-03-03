import 'package:flutter/material.dart';

class QuizSolverController {
  final String mode;
  int currentQuestionIndex = 0;
  int? selectedOptionIndex;
  bool isAnswerSubmitted = false;

  // Mock Questions Data (To be replaced with API later)
  final List<Map<String, dynamic>> questions = [
    {
      'id': 1,
      'content': '다음에 해당하는 토양 단면의 층위는?',
      'hint': '유기물이 갓 쌓여 분해중인 층',
      'options': ['O층 (유기물층)', 'A층 (용탈층)', 'B층 (집적층)', 'C층 (모재층)'],
      'correct_index': 0,
      'explanation': 'O층은 산림 토양에서 주로 나타나며 낙엽 등이 쌓여있는 층위입니다.',
    },
    {
      'id': 2,
      'content':
          '다음 수식 식물의 광합성 속도 P를 구하시오. \$\$ P = \\frac{1}{R_s + R_m} \\cdot \\Delta C \$\$ 에서 \$ R_s \$ 가 의미하는 바는?',
      'hint': '',
      'options': ['기공 저항', '엽육 저항', '광호흡', '증산량'],
      'correct_index': 0,
      'explanation':
          '광합성 모델에서 R_s는 기공이 이산화탄소를 흡수할 때 느끼는 저항(Stomatal Resistance)입니다.',
    },
  ];

  QuizSolverController({required this.mode});

  bool get isLastQuestion => currentQuestionIndex >= questions.length - 1;
  double get progress => currentQuestionIndex / questions.length;
  Map<String, dynamic> get currentQuestion => questions[currentQuestionIndex];

  void selectOption(int index) {
    if (isAnswerSubmitted) return;
    selectedOptionIndex = index;
  }

  void submitAnswer() {
    if (selectedOptionIndex == null) return;
    isAnswerSubmitted = true;
  }

  bool nextQuestion() {
    if (!isLastQuestion) {
      currentQuestionIndex++;
      selectedOptionIndex = null;
      isAnswerSubmitted = false;
      return true;
    }
    return false;
  }
}
