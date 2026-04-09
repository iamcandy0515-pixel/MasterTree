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
      final Map<String, dynamic> data = await ApiService.generateQuizSession(
        mode: mode == 'random' || mode == 'weakness' ? 'pastExam' : mode,
        limit: 10,
      );

      sessionId = data['session_id'] as int?;
      final List<dynamic> rawQs = (data['questions'] as List<dynamic>?) ?? <dynamic>[];

      questions = rawQs.map((dynamic qRaw) {
        final Map<String, dynamic> q = Map<String, dynamic>.from(qRaw as Map);
        // 현재 UI 구조가 단일 String을 기대하므로 블록들을 문자열로 병합
        final String content = _flattenBlocks(q['content_blocks']);
        final String explanation = _flattenBlocks(q['explanation_blocks']);
        final List<String> options = (q['options'] as List<dynamic>).map((dynamic o) => _flattenBlocks(<dynamic>[o])).toList();

        return <String, dynamic>{
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
      errorMessage = "$e";
      onUpdate();
    }
  }

  String _flattenBlocks(dynamic blocks) {
    if (blocks == null) return '';
    if (blocks is String) return blocks;
    if (blocks is List) {
      final content = blocks.map((dynamic b) {
        if (b is Map) {
          return "${b['content'] ?? ''}";
        }
        return "$b";
      }).join('\n');
      return content;
    }
    return "$blocks";
  }

  bool get isLastQuestion => questions.isEmpty ? true : currentQuestionIndex >= questions.length - 1;
  double get progress {
    if (questions.isEmpty) return 0.0;
    final double val = (currentQuestionIndex + 1) / questions.length;
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

    final Map<String, dynamic> q = currentQuestion;
    final bool isCorrect = selectedOptionIndex == (q['correct_index'] as int);

    // 1. 서버에 즉시 저장 시도 (Phase 3 요구사항)
    ApiService.submitQuizAttempt(
      questionId: q['id'] as int,
      sessionId: sessionId,
      categoryId: q['category_id'] as int?,
      isCorrect: isCorrect,
      userAnswer: selectedOptionIndex?.toString() ?? '',
      timeTakenMs: 0, // 추후 필요시 타이머 추가 가능
    );

    // 2. 오프라인 대비 및 배치 동기화를 위해 기존 큐에도 추가 (중복 방지는 서버가 처리)
    ApiService.addPendingAttempt(<String, dynamic>{
      'session_id': sessionId,
      'question_id': q['id'],
      'category_id': q['category_id'],
      'is_correct': isCorrect,
      'user_answer': selectedOptionIndex?.toString() ?? '',
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
