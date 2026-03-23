import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../repositories/quiz_repository.dart';
import 'parts/quiz_file_handler_mixin.dart';
import 'parts/quiz_ai_assistant_mixin.dart';
import 'parts/quiz_image_handler_mixin.dart';

class QuizExtractionStep2ViewModel extends ChangeNotifier
    with QuizFileHandlerMixin, QuizAiAssistantMixin, QuizImageHandlerMixin {
  
  final QuizRepository _mainRepo = QuizRepository();

  int _hintsCount = 2;
  int _selectedQuestion = 1;
  int _correctOptionIndex = 0;
  String? _initialSubject;
  int? _initialYear, _initialRound;
  bool _isLoading = false, _isSaving = false;
  double _extractionProgress = 0.0;

  // Getters
  int get hintsCount => _hintsCount;
  int get selectedQuestion => _selectedQuestion;
  int get correctOptionIndex => _correctOptionIndex;
  String? get initialSubject => _initialSubject;
  int? get initialYear => _initialYear;
  int? get initialRound => _initialRound;
  
  bool get isLoading => _isLoading || isSearching || isValidating || isExtractingInternal || isRecommending || isReviewing || isImageLoading;
  bool get isSaving => _isSaving;
  bool get isExtracting => isExtractingInternal;
  double get extractionProgress => _extractionProgress;
  
  // UI Compatibility Getters
  int get selectedQuestionNumber => _selectedQuestion;
  List<Map<String, dynamic>> get relatedQuizzes => relatedQuestions;
  String? get selectedSubject => _initialSubject;
  int? get selectedYear => _initialYear;
  int? get selectedRound => _initialRound;
  String? get extractedSubject => _initialSubject;
  int? get extractedYear => _initialYear;
  int? get extractedRound => _initialRound;
  Map<String, dynamic>? get extractedBlock => validatedQuizData;

  void setHintsCount(int count) {
    if (count > 0 && count <= 5) { _hintsCount = count; notifyListeners(); }
  }

  void setInitialFilter(String? subject, int? year, int? round) {
    _initialSubject = subject; _initialYear = year; _initialRound = round;
  }

  void setSelectedQuestion(int question) { _selectedQuestion = question; notifyListeners(); }

  void updateFilters({String? subject, int? year, int? round, int? questionNumber}) {
    if (subject != null) _initialSubject = subject;
    if (year != null) _initialYear = year;
    if (round != null) _initialRound = round;
    if (questionNumber != null) _selectedQuestion = questionNumber;
    notifyListeners();
  }

  // Wrapper for parameterless extraction
  Future<Map<String, dynamic>> extractQuiz() => extractQuizInternal(_selectedQuestion, _hintsCount);

  Map<String, dynamic> populateExtractedQuiz() {
    if (validatedQuizData == null) throw '문제를 먼저 추출해주세요.';
    _correctOptionIndex = validatedQuizData!['correct_option_index'] ?? 0;
    notifyListeners();
    return validatedQuizData!;
  }

  Future<void> saveToDb({
    required String questionText,
    required String explanationText,
    required List<String> hintTexts,
    required List<String> optionTexts,
  }) async {
    if (validatedQuizData == null) throw '추출된 데이터가 없습니다.';
    if (_initialSubject == null || _initialYear == null || _initialRound == null) throw '필수 정보가 누락되었습니다.';

    _isSaving = true; notifyListeners();

    try {
      final data = {
        'raw_source_text': validatedQuizData!['raw_source_text'],
        'subject': _initialSubject,
        'year': _initialYear,
        'round': _initialRound,
        'question_number': _selectedQuestion,
        'content_blocks': [{'type': 'text', 'content': questionText}],
        'explanation_blocks': [{'type': 'text', 'content': explanationText}],
        'hint_blocks': hintTexts.take(_hintsCount).map((t) => {'type': 'text', 'content': t}).toList(),
        'options': optionTexts.take(4).map((t) => {'type': 'text', 'content': t}).toList(),
        'correct_option_index': _correctOptionIndex,
        'difficulty': 1,
      };
      await _mainRepo.upsertQuizQuestion(data);
    } finally {
      _isSaving = false; notifyListeners();
    }
  }

  // UI Match Wrappers
  Future<void> saveCurrentQuizToDbAction({required String question, required String explanation, required List<String> options, required List<String> hints}) 
    => saveToDb(questionText: question, explanationText: explanation, optionTexts: options, hintTexts: hints);

  Future<List<String>> generateOptionsAction(String q, String a) => generateDistractorsAction(q, a);
  Future<void> recommendSimilarAction(String q) => recommendRelatedAction(q);
  Future<List<String>> generateHintsAction(String q, String e) => generateHintsInternal(q, e, _hintsCount);
  Future<Map<String, dynamic>> reviewExplanationAction(String e) => reviewExplanationInternal(e, validatedQuizData);
  
  Future<void> startBatchExtractionAction({required String fileId, required int singleQuestionNumber, required Function(int current, int total) onProgress, required Function(String message) onMessage}) async {
    setSelectedFileId(fileId);
    _selectedQuestion = singleQuestionNumber;
    _isLoading = true; _extractionProgress = 0.0;
    notifyListeners();
    try {
      await extractQuiz();
      populateExtractedQuiz();
      onProgress(1, 1);
      _extractionProgress = 1.0;
    } catch (e) {
      onMessage(e.toString()); rethrow;
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  // Image Wrappers matching original names
  Future<void> addImageToQuiz(String field, XFile file) => addImageToQuizInternal(field, file, validatedQuizData);
  bool hasImage(String field) => hasImageInternal(field, validatedQuizData);
  void removeImage(String field, int index) => removeImageInternal(field, index, validatedQuizData);
}
