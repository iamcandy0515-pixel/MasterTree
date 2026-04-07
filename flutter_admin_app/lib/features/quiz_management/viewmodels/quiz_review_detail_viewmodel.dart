// ignore_for_file: prefer_final_fields
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/quiz_repository.dart';
import '../repositories/quiz_ai_repository.dart';
import '../repositories/quiz_media_repository.dart';

part 'parts/quiz_ai_logic.part.dart';
part 'parts/quiz_media_logic.part.dart';
part 'parts/quiz_ui_state.part.dart';

class QuizReviewDetailViewModel extends ChangeNotifier {
  final QuizRepository _repository = QuizRepository();
  final QuizAiRepository _aiRepo = QuizAiRepository();
  final QuizMediaRepository _mediaRepo = QuizMediaRepository();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isReviewing = false;
  bool _isGenerating = false;
  bool _isRecommending = false;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isReviewing => _isReviewing;
  bool get isGenerating => _isGenerating;
  bool get isRecommending => _isRecommending;

  // Question Info
  String subject = '';
  String year = '';
  String round = '';
  String questionNo = '';

  // Blocks & Data
  List<dynamic> contentBlocks = <dynamic>[];
  List<dynamic> explanationBlocks = <dynamic>[];
  List<dynamic> hintBlocks = <dynamic>[];
  String questionText = '';
  String explanationText = '';
  String hintText = '';
  String correctOption = '';
  List<String> incorrectOptions = [];
  int correctOptionIndex = 0;

  // Expand status
  bool isContentExpanded = false;
  bool isExpExpanded = false;

  // Related
  List<int> selectedRelatedIds = [];
  List<Map<String, dynamic>> relatedQuizzesMetadata = [];
  int currentRelatedPage = 0;



  Future<void> loadQuiz(int quizId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final dynamic response = await Supabase.instance.client
          .from('quiz_questions')
          .select<PostgrestList>('*, quiz_exams(year, round), quiz_categories(name)')
          .eq('id', quizId)
          .single();

      final exam = response['quiz_exams'] as Map<String, dynamic>?;
      final category = response['quiz_categories'] as Map<String, dynamic>?;

      subject = category?['name']?.toString() ?? '-';
      year = exam?['year']?.toString() ?? '-';
      round = exam?['round']?.toString() ?? '-';
      questionNo = response['question_number']?.toString() ?? response['id'].toString();

      selectedRelatedIds = (response['related_quiz_ids'] as List<dynamic>?)
              ?.map((dynamic e) => int.tryParse(e.toString()) ?? 0).toList().cast<int>() ?? <int>[];

      if (selectedRelatedIds.isNotEmpty) {
        await loadRelatedQuizzesMetadata();
      }

      contentBlocks = response['content_blocks'] as List<dynamic>? ?? <dynamic>[];
      questionText = _extractTextFromBlocks(contentBlocks);

      explanationBlocks = response['explanation_blocks'] as List<dynamic>? ?? <dynamic>[];
      explanationText = _extractTextFromBlocks(explanationBlocks);

      hintBlocks = response['hint_blocks'] as List<dynamic>? ?? <dynamic>[];
      hintText = _extractTextFromBlocks(hintBlocks);

      final options = response['options'] as List<dynamic>? ?? <dynamic>[];
      correctOptionIndex = (response['correct_option_index'] as int?) ?? 0;
      incorrectOptions.clear();
      for (int i = 0; i < options.length; i++) {
        final dynamic content = options[i]['content'] ?? '';
        if (i == correctOptionIndex) {
          correctOption = content as String? ?? '';
        } else {
          incorrectOptions.add(content as String? ?? '');
        }
      }
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      rethrow;
    }
    notifyListeners();
  }

  Future<void> saveQuiz(int quizId) async {
    _isSaving = true;
    notifyListeners();
    try {
      final newOptions = [{'type': 'text', 'content': correctOption}];
      for (var opt in incorrectOptions) {
        newOptions.add({'type': 'text', 'content': opt});
      }

      final newContent = _updateTextInBlocks(contentBlocks, questionText);
      final newExp = _updateTextInBlocks(explanationBlocks, explanationText);
      final newHint = [{'type': 'text', 'content': hintText}];

      await _repository.upsertQuizQuestion(<String, dynamic>{
        'id': quizId,
        'subject': subject,
        'year': int.tryParse(year),
        'round': int.tryParse(round),
        'question_number': int.tryParse(questionNo) ?? int.parse(quizId.toString()),
        'content_blocks': newContent,
        'question_text': questionText,
        'explanation_blocks': newExp,
        'explanation_text': explanationText,
        'hint_blocks': newHint,
        'hint_text': hintText,
        'options': newOptions,
        'correct_option_index': 0,
        'status': 'published',
        'related_quiz_ids': selectedRelatedIds,
      });
      _isSaving = false;
    } catch (e) {
      _isSaving = false;
      rethrow;
    }
    notifyListeners();
  }

  List<dynamic> _updateTextInBlocks(List<dynamic> blocks, String text) {
    final List<dynamic> newBlocks = List<dynamic>.from(blocks);
    int idx = newBlocks.indexWhere((dynamic b) => b is String || (b is Map && b['type'] == 'text'));
    if (idx != -1) {
      newBlocks.removeWhere((dynamic b) => b is String || (b is Map && b['type'] == 'text'));
      newBlocks.insert(idx.clamp(0, newBlocks.length), {'type': 'text', 'content': text});
    } else {
      newBlocks.insert(0, {'type': 'text', 'content': text});
    }
    return newBlocks;
  }

  Future<void> loadRelatedQuizzesMetadata() async {
    try {
      final dynamic response = await Supabase.instance.client
          .from('quiz_questions')
          .select<PostgrestList>('id, question_number, quiz_exams(year, round, title), quiz_categories(name), content_blocks')
          .filter('id', 'in', selectedRelatedIds);
      
      relatedQuizzesMetadata = List<Map<String, dynamic>>.from(response as List);
      relatedQuizzesMetadata.sort((a, b) {
        final dynamic yearA = a['quiz_exams']?['year'] ?? 0;
        final dynamic yearB = b['quiz_exams']?['year'] ?? 0;
        return yearA != yearB ? (yearB as num).compareTo(yearA as num) : ((b['quiz_exams']?['round'] ?? 0) as num).compareTo((a['quiz_exams']?['round'] ?? 0) as num);
      });
      notifyListeners();
    } catch (e) { 
      debugPrint('Error loading related metadata: $e'); 
    }
  }
}
