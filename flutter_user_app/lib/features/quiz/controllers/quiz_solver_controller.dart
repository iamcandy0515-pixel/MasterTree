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
      // QuizSolverScreen에서 전달받은 mode가 'random' 이더라도 
      // 기출문제 질문을 가져오기 위해 'pastExam' 모드를 기본으로 사용하거나 
      // 전달받은 모드가 있으면 해당 모드를 사용하도록 수정
      final data = await ApiService.generateQuizSession(
        mode: mode == 'random' || mode == 'weakness' ? 'pastExam' : mode,
        limit: 10,
      );

      sessionId = data['session_id'];
      final List<dynamic> rawQs = data['questions'] ?? [];

      questions = rawQs.map((q) {
        // UI가 블록 기반 렌더링(QuizContentRenderer)을 수행하므로 원본 리스트 보존
        dynamic content = q['content_blocks'] ?? [];
        dynamic explanation = q['explanation_blocks'] ?? [];
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
  double get progress {
    if (questions.isEmpty) return 0.0;
    double val = (currentQuestionIndex + 1) / questions.length;
    return val.isFinite ? val : 0.0;
  }
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

    // 1. 서버에 즉시 저장 시도 (Phase 3 요구사항)
    ApiService.submitQuizAttempt(
      questionId: q['id'] as int,
      sessionId: sessionId,
      categoryId: q['category_id'] as int?,
      isCorrect: isCorrect,
      userAnswer: selectedOptionIndex.toString(),
      timeTakenMs: 0, // 추후 필요시 타이머 추가 가능
    );

    // 2. 오프라인 대비 및 배치 동기화를 위해 기존 큐에도 추가 (중복 방지는 서버가 처리)
    ApiService.addPendingAttempt({
      'session_id': sessionId,
      'question_id': q['id'],
      'category_id': q['category_id'],
      'is_correct': isCorrect,
      'user_answer': selectedOptionIndex.toString(),
      'time_taken_ms': 0,
      'mode': mode == 'random' || mode == 'weakness' ? 'pastExam' : mode,
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
