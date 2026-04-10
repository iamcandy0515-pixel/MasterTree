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

  List<dynamic> contentBlocks = <dynamic>[];
  List<dynamic> explanationBlocks = <dynamic>[];

  List<String> options = <String>[];
  int correctOptionIndex = 0;

  List<Map<String, dynamic>> similarQuizzes = <Map<String, dynamic>>[];

  int? selectedOptionIndex;
  bool isAnswered = false;

  void selectOption(int index, {required VoidCallback onUpdate}) {
    if (isAnswered) return;
    selectedOptionIndex = index;
    isAnswered = true;

    // 분석을 위해 큐에 추가 (배치를 위해)
    if (quizId != null) {
      ApiService.addPendingAttempt(<String, dynamic>{
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
      final SupabaseClient supabase = Supabase.instance.client;
      final Map<String, dynamic> response = await supabase
          .from('quiz_questions')
          .select<PostgrestMap>('*, quiz_exams(year, round), quiz_categories(id, name)')
          .eq('id', quizId)
          .single();

      final Map<String, dynamic>? exam = response['quiz_exams'] as Map<String, dynamic>?;
      final Map<String, dynamic>? category = response['quiz_categories'] as Map<String, dynamic>?;

      this.quizId = quizId;
      categoryId = category?['id'] as int?;

      subject = "${category?['name'] ?? '-'}";
      year = "${exam?['year'] ?? '-'}";
      round = "${exam?['round'] ?? '-'}";
      questionNo = "${response['question_number'] ?? response['id'] ?? ''}";

      // Parse content
      contentBlocks = response['content_blocks'] as List<dynamic>? ?? <dynamic>[];
      if (contentBlocks.isNotEmpty) {
        final dynamic firstText = contentBlocks.firstWhere(
          (dynamic b) => (b as Map<String, dynamic>)['type'] == 'text',
          orElse: () => null,
        );
        questionText = formatText((firstText as Map<String, dynamic>?)?['content']?.toString() ?? '');
      }

      explanationBlocks =
          response['explanation_blocks'] as List<dynamic>? ?? <dynamic>[];
      if (explanationBlocks.isNotEmpty) {
        final dynamic firstText = explanationBlocks.firstWhere(
          (dynamic b) => (b as Map<String, dynamic>)['type'] == 'text',
          orElse: () => null,
        );
        explanationText = formatExplanation(
          formatText((firstText as Map<String, dynamic>?)?['content']?.toString() ?? ''),
        );
      }

      final List<dynamic>? hintBlocks = response['hint_blocks'] as List<dynamic>?;
      if (hintBlocks != null && hintBlocks.isNotEmpty) {
        hintText = formatText(
          hintBlocks
              .map(
                (dynamic h) =>
                    h is Map ? "${h['content'] ?? ''}" : "$h",
              )
              .join('\n'),
        );
      }

      final List<dynamic> optionsData = response['options'] as List<dynamic>? ?? <dynamic>[];
      correctOptionIndex = (response['correct_option_index'] as int?) ?? 0;
      options = optionsData
          .map((dynamic o) => formatText((o as Map<String, dynamic>)['content']?.toString() ?? ''))
          .toList();

      // Fetch similar quizzes by ID if available, fallback to category search
      // Fetch similar quizzes only by explicit IDs
      final List<dynamic> relatedIds = response['related_quiz_ids'] as List<dynamic>? ?? <dynamic>[];
      if (relatedIds.isNotEmpty) {
        final List<dynamic> similarResponse = await supabase
            .from('quiz_questions')
            .select<PostgrestList>('*, quiz_exams(year, round, title), quiz_categories(name)')
            .filter('id', 'in', relatedIds)
            .limit(10);
        
        similarQuizzes = similarResponse.map((dynamic e) => Map<String, dynamic>.from(e as Map)).toList();

        // 연도 및 회차 내림차순(최신순) 정렬
        similarQuizzes.sort((Map<String, dynamic> a, Map<String, dynamic> b) {
          final dynamic yearA = (a['quiz_exams'] as Map<String, dynamic>?)?['year'] ?? 0;
          final dynamic yearB = (b['quiz_exams'] as Map<String, dynamic>?)?['year'] ?? 0;
          if (yearA != yearB) {
            return (yearB as int).compareTo(yearA as int);
          } else {
            final dynamic roundA = (a['quiz_exams'] as Map<String, dynamic>?)?['round'] ?? 0;
            final dynamic roundB = (b['quiz_exams'] as Map<String, dynamic>?)?['round'] ?? 0;
            return (roundB as int).compareTo(roundA as int);
          }
        });
      } else {
        similarQuizzes = <Map<String, dynamic>>[];
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
    final List<String> keywords = <String>['풀이순서', '공식', '공식대입 및 계산', '정답'];
    for (final String kw in keywords) {
      // 키워드 앞에 줄바꿈을 추가하여 구분
      result = result.replaceAll(kw, '\n$kw');
    }
    return result.trim();
  }
}
