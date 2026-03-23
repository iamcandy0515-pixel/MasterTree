import 'package:flutter_user_app/models/quiz_model.dart';

mixin QuizStateMixin {
  List<QuizQuestion> questions = [];
  bool isLoading = true;
  int currentIndex = 0;
  String selectedHint = '대표';
  final Set<String> viewedHints = {'대표'};
  bool showHintMessage = false;
  int? selectedAnswer;
  bool isCorrect = false;
  bool showDescription = false;
  int correctCount = 0;
  int accumulatedHintCount = 0;

  void resetState() {
    selectedAnswer = null;
    isCorrect = false;
    showDescription = false;
    showHintMessage = false;
    selectedHint = '대표';
    viewedHints.clear();
    viewedHints.add('대표');
  }

  bool get hasNext => currentIndex < questions.length - 1;
  int get totalQuestions => questions.length;
  int get viewedHintsCount => viewedHints.length;
}
