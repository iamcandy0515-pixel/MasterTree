import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/api_service.dart';

class PastExamDetailController {
  bool isLoading = true;
  int? quizId; // 문제 ID 저장용
  int? categoryId; // 카테고리 ID 저장용

  String subject = '';
  String year = '';
  String round = '';
  String questionNo = '';

  String questionText = '';
  String explanationText = '';
  String hintText = '';

  List<dynamic> contentBlocks = [];
  List<dynamic> explanationBlocks = [];

  List<String> options = [];
  int correctOptionIndex = 0;

  List<Map<String, dynamic>> similarQuizzes = [];

  int? selectedOptionIndex;
  bool isAnswered = false;

  void selectOption(int index, {required VoidCallback onUpdate}) {
    if (isAnswered) return;
    selectedOptionIndex = index;
    isAnswered = true;

    // 분석을 위해 큐에 추가 (배치를 위해)
    if (quizId != null) {
      ApiService.addPendingAttempt({
        'question_id': quizId!,
        'category_id': categoryId,
        'is_correct': (index == correctOptionIndex),
        'user_answer': index,
        'time_taken_ms': 0,
        'mode': 'pastExam',
      });
    }

    onUpdate();
  }

  Future<void> fetchQuizData({
    required int quizId,
    required VoidCallback onUpdate,
    required Function(String) onError,
  }) async {
    isLoading = true;
    onUpdate();

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('quiz_questions')
          .select('*, quiz_exams(year, round), quiz_categories(id, name)')
          .eq('id', quizId)
          .single();

      final exam = response['quiz_exams'] as Map<String, dynamic>?;
      final category = response['quiz_categories'] as Map<String, dynamic>?;

      this.quizId = quizId;
      this.categoryId = category?['id'] as int?;

      subject = category?['name']?.toString() ?? '-';
      year = exam?['year']?.toString() ?? '-';
      round = exam?['round']?.toString() ?? '-';
      questionNo =
          response['question_number']?.toString() ?? response['id'].toString();

      // Parse content
      contentBlocks = response['content_blocks'] as List<dynamic>? ?? [];
      if (contentBlocks.isNotEmpty) {
        final firstText = contentBlocks.firstWhere(
          (b) => b['type'] == 'text',
          orElse: () => null,
        );
        questionText = formatText(firstText?['content'] ?? '');
      }

      explanationBlocks =
          response['explanation_blocks'] as List<dynamic>? ?? [];
      if (explanationBlocks.isNotEmpty) {
        final firstText = explanationBlocks.firstWhere(
          (b) => b['type'] == 'text',
          orElse: () => null,
        );
        explanationText = formatExplanation(
          formatText(firstText?['content'] ?? ''),
        );
      }

      final hintBlocks = response['hint_blocks'] as List<dynamic>?;
      if (hintBlocks != null && hintBlocks.isNotEmpty) {
        hintText = formatText(
          hintBlocks
              .map(
                (h) =>
                    h is Map ? (h['content']?.toString() ?? '') : h.toString(),
              )
              .join('\n'),
        );
      }

      final optionsData = response['options'] as List<dynamic>? ?? [];
      correctOptionIndex = response['correct_option_index'] ?? 0;
      options = optionsData
          .map((o) => formatText(o['content']?.toString() ?? ''))
          .toList();

      // Fetch similar quizzes by ID if available, fallback to category search
      // Fetch similar quizzes only by explicit IDs
      final relatedIds = response['related_quiz_ids'] as List<dynamic>? ?? [];
      if (relatedIds.isNotEmpty) {
        final similarResponse = await supabase
            .from('quiz_questions')
            .select('*, quiz_exams(year, round, title), quiz_categories(name)')
            .filter('id', 'in', relatedIds)
            .limit(10);
        similarQuizzes = List<Map<String, dynamic>>.from(similarResponse);

        // 연도 및 회차 내림차순(최신순) 정렬
        similarQuizzes.sort((a, b) {
          final yearA = a['quiz_exams']?['year'] ?? 0;
          final yearB = b['quiz_exams']?['year'] ?? 0;
          if (yearA != yearB) {
            return yearB.compareTo(yearA);
          } else {
            final roundA = a['quiz_exams']?['round'] ?? 0;
            final roundB = b['quiz_exams']?['round'] ?? 0;
            return roundB.compareTo(roundA);
          }
        });
      } else {
        similarQuizzes = [];
      }

      isLoading = false;
    } catch (e) {
      debugPrint('Error fetching quiz data: $e');
      isLoading = false;
      onError(e.toString());
    } finally {
      onUpdate();
    }
  }

  String formatText(String text) {
    if (text.isEmpty) return text;
    // 모든 줄바꿈 특수문자(\n)를 공백으로 치환하고 중복 공백 정리
    return text.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String formatExplanation(String text) {
    if (text.isEmpty) return text;
    // 계산문제 키워드: '풀이순서', '공식', '공식대입 및 계산', '정답' 앞에는 줄바꿈 추가
    String result = text;
    final keywords = ['풀이순서', '공식', '공식대입 및 계산', '정답'];
    for (var kw in keywords) {
      // 키워드 앞에 줄바꿈을 추가하여 구분
      result = result.replaceAll(kw, '\n$kw');
    }
    return result.trim();
  }
}
