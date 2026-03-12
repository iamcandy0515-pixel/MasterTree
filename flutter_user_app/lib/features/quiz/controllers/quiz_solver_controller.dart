import 'package:flutter/material.dart';
import '../../../core/api_service.dart';

class QuizSolverController {
  final String mode;
  int currentQuestionIndex = 0;
  int? selectedOptionIndex;
  bool isAnswerSubmitted = false;
  bool isLoading = true;
  String? errorMessage;

  List<Map<String, dynamic>> questions = [];
  int? sessionId;

  QuizSolverController({required this.mode});

  Future<void> init(VoidCallback onUpdate) async {
    isLoading = true;
    errorMessage = null;
    onUpdate();

    try {
      // 기출문제 모드면 'pastExam', 아니면 'normal' (수목퀴즈)
      // QuizSolverScreen은 기출문제용이므로 기본적으로 'pastExam' 사용
      final data = await ApiService.generateQuizSession(
        mode: 'pastExam',
        limit: 10,
      );

      sessionId = data['session_id'];
      final List<dynamic> rawQs = data['questions'] ?? [];

      questions = rawQs.map((q) {
        // 현재 UI 구조가 단일 String을 기대하므로 블록들을 문자열로 병합
        String content = _flattenBlocks(q['content_blocks']);
        String explanation = _flattenBlocks(q['explanation_blocks']);
        List<String> options = (q['options'] as List).map((o) => _flattenBlocks([o])).toList();

        return {
          'id': q['id'],
          'category_id': q['category_id'],
          'content': content,
          'options': options,
          'correct_index': q['correct_option_index'] ?? 0,
          'explanation': explanation,
        };
      }).toList();

      isLoading = false;
      onUpdate();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      onUpdate();
    }
  }

  String _flattenBlocks(dynamic blocks) {
    if (blocks == null) return '';
    if (blocks is String) return blocks;
    if (blocks is List) {
      return blocks.map((b) {
        if (b is Map && b.containsKey('content')) {
          return b['content'].toString();
        }
        return b.toString();
      }).join('\n');
    }
    return blocks.toString();
  }

  bool get isLastQuestion => questions.isEmpty ? true : currentQuestionIndex >= questions.length - 1;
  double get progress => questions.isEmpty ? 0 : (currentQuestionIndex + 1) / questions.length;
  Map<String, dynamic> get currentQuestion => questions[currentQuestionIndex];

  void selectOption(int index) {
    if (isAnswerSubmitted) return;
    selectedOptionIndex = index;
  }

  void submitAnswer() {
    if (selectedOptionIndex == null || isAnswerSubmitted) return;
    isAnswerSubmitted = true;

    final q = currentQuestion;
    final isCorrect = selectedOptionIndex == q['correct_index'];

    // 학습 결과 큐에 추가 (배치 전송을 위해 보관)
    ApiService.addPendingAttempt({
      'session_id': sessionId,
      'question_id': q['id'],
      'category_id': q['category_id'],
      'is_correct': isCorrect,
      'user_answer': selectedOptionIndex.toString(),
      'time_taken_ms': 0,
      'mode': 'pastExam',
    });
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
