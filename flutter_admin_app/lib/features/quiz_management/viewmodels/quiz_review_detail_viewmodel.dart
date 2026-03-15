import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/quiz_repository.dart';

class QuizReviewDetailViewModel extends ChangeNotifier {
  final QuizRepository _repository = QuizRepository();

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
  List<dynamic> contentBlocks = [];
  List<dynamic> explanationBlocks = [];
  List<dynamic> hintBlocks = [];
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
      final response = await Supabase.instance.client
          .from('quiz_questions')
          .select('*, quiz_exams(year, round), quiz_categories(name)')
          .eq('id', quizId)
          .single();

      final exam = response['quiz_exams'] as Map<String, dynamic>?;
      final category = response['quiz_categories'] as Map<String, dynamic>?;

      subject = category?['name']?.toString() ?? '-';
      year = exam?['year']?.toString() ?? '-';
      round = exam?['round']?.toString() ?? '-';
      questionNo = response['question_number']?.toString() ?? response['id'].toString();

      selectedRelatedIds = (response['related_quiz_ids'] as List<dynamic>?)
              ?.map((e) => int.parse(e.toString())).toList() ?? [];

      if (selectedRelatedIds.isNotEmpty) loadRelatedQuizzesMetadata();

      contentBlocks = response['content_blocks'] as List<dynamic>? ?? [];
      questionText = _extractTextFromBlocks(contentBlocks);

      explanationBlocks = response['explanation_blocks'] as List<dynamic>? ?? [];
      explanationText = _extractTextFromBlocks(explanationBlocks);

      hintBlocks = response['hint_blocks'] as List<dynamic>? ?? [];
      hintText = _extractTextFromBlocks(hintBlocks);

      final options = response['options'] as List<dynamic>? ?? [];
      correctOptionIndex = response['correct_option_index'] ?? 0;
      incorrectOptions.clear();
      for (int i = 0; i < options.length; i++) {
        final content = options[i]['content'] ?? '';
        if (i == correctOptionIndex) {
          correctOption = content;
        } else {
          incorrectOptions.add(content);
        }
      }
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      rethrow;
    }
    notifyListeners();
  }

  String _extractTextFromBlocks(List<dynamic> blocks) {
    return blocks.map((b) {
      if (b is Map && b['type'] == 'text') return b['content']?.toString() ?? '';
      if (b is String) return b;
      return '';
    }).where((t) => t.isNotEmpty).join('\n');
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

      await _repository.upsertQuizQuestion({
        'id': quizId,
        'content_blocks': newContent,
        'explanation_blocks': newExp,
        'hint_blocks': newHint,
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
    final newBlocks = List.from(blocks);
    int idx = newBlocks.indexWhere((b) => b is String || (b is Map && b['type'] == 'text'));
    if (idx != -1) {
      newBlocks.removeWhere((b) => b is String || (b is Map && b['type'] == 'text'));
      newBlocks.insert(idx.clamp(0, newBlocks.length), {'type': 'text', 'content': text});
    } else {
      newBlocks.insert(0, {'type': 'text', 'content': text});
    }
    return newBlocks;
  }

  Future<Map<String, dynamic>> aiReview() async {
    _isReviewing = true;
    notifyListeners();
    try {
      final rawText = relatedQuizzesMetadata.isNotEmpty ? _extractTextFromBlocks(relatedQuizzesMetadata.first['content_blocks'] ?? []) : '';
      final res = await _repository.reviewQuizAlignment(rawText, [{'type': 'text', 'content': explanationText}]);
      _isReviewing = false;
      notifyListeners();
      return res;
    } catch (e) {
      _isReviewing = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> generateDistractors() async {
    _isGenerating = true;
    notifyListeners();
    try {
      final distractors = await _repository.generateDistractors(questionText, correctOption);
      incorrectOptions = distractors;
      _isGenerating = false;
    } catch (e) {
      _isGenerating = false;
      rethrow;
    }
    notifyListeners();
  }

  Future<List<dynamic>> recommendSimilar(int quizId) async {
    _isRecommending = true;
    notifyListeners();
    try {
      final related = await _repository.recommendRelated(questionText: questionText);
      _isRecommending = false;
      notifyListeners();
      return related.where((r) => r['id'] != quizId).toList();
    } catch (e) {
      _isRecommending = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadRelatedQuizzesMetadata() async {
    try {
      final response = await Supabase.instance.client.from('quiz_questions').select('id, question_number, quiz_exams(year, round, title), quiz_categories(name), content_blocks').filter('id', 'in', selectedRelatedIds);
      relatedQuizzesMetadata = List<Map<String, dynamic>>.from(response);
      relatedQuizzesMetadata.sort((a, b) {
        final yearA = a['quiz_exams']?['year'] ?? 0;
        final yearB = b['quiz_exams']?['year'] ?? 0;
        return yearA != yearB ? yearB.compareTo(yearA) : (b['quiz_exams']?['round'] ?? 0).compareTo(a['quiz_exams']?['round'] ?? 0);
      });
      notifyListeners();
    } catch (e) { debugPrint(e.toString()); }
  }

  Future<void> uploadImage(Uint8List bytes, String name, String field) async {
    final url = await _repository.uploadQuizImage(bytes, name);
    if (field == 'content') {
      contentBlocks.add({'type': 'image', 'content': url});
    } else {
      explanationBlocks.add({'type': 'image', 'content': url});
    }
    notifyListeners();
  }

  void removeImage(int blockIdx, String field) {
    if (field == 'content') {
      contentBlocks.removeAt(blockIdx);
    } else {
      explanationBlocks.removeAt(blockIdx);
    }
    notifyListeners();
  }

  void toggleExpanded(String field) {
    if (field == 'content') {
      isContentExpanded = !isContentExpanded;
    } else {
      isExpExpanded = !isExpExpanded;
    }
    notifyListeners();
  }

  void setRelatedPage(int page) { currentRelatedPage = page; notifyListeners(); }
  void removeRelated(int id) {
    selectedRelatedIds.remove(id);
    relatedQuizzesMetadata.removeWhere((m) => m['id'] == id);
    notifyListeners();
  }
}
