import 'dart:async';
import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../models/quiz_model.dart';
import 'quiz_data_handler.dart';

class QuizViewModel extends ChangeNotifier with QuizDataHandler {
  List<QuizQuestion> _questions = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  String _selectedHint = '전체';
  final Set<String> _viewedHints = {'전체'};
  bool _showHintMessage = false;
  Timer? _hintTimer;
  int? _selectedAnswer;
  bool _isCorrect = false;
  bool _showDescription = false;
  Timer? _descriptionTimer;
  int _correctCount = 0;
  int _accumulatedHintCount = 0;

  // Getters
  List<QuizQuestion> get questions => _questions;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  String get selectedHint => _selectedHint;
  bool get showHintMessage => _showHintMessage;
  Set<String> get viewedHints => _viewedHints;
  int get viewedHintsCount => _viewedHints.length;
  int? get selectedAnswer => _selectedAnswer;
  bool get isCorrect => _isCorrect;
  bool get showDescription => _showDescription;
  int get correctCount => _correctCount;
  int get accumulatedHintCount => _accumulatedHintCount;
  int get totalQuestions => _questions.length;
  bool get hasNext => _currentIndex < _questions.length - 1;
  int get solvedCount =>
      _selectedAnswer != null ? _currentIndex + 1 : _currentIndex;

  QuizQuestion get currentQuestion =>
      _questions.isNotEmpty ? _questions[_currentIndex] : _getDummyQuestion();

  String get currentHintText {
    final text = currentQuestion.hints[_selectedHint];
    if (text == null || text.trim().isEmpty || text == '정보 없음') {
      return '해당 힌트 정보가 없습니다.';
    }
    return text;
  }

  Future<void> initialize() async {
    await fetchQuestionsFromApi();
  }

  Future<void> fetchQuestionsFromApi() async {
    _isLoading = true;
    notifyListeners();

    try {
      final List<Map<String, dynamic>> data = await ApiService.getTrees(
        limit: 100,
        minimal: false,
      );
      if (data.isNotEmpty) {
        _questions = processQuizData(data);
      } else {
        _questions = getDummyQuestions();
      }
    } catch (e) {
      _questions = getDummyQuestions();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  QuizQuestion _getDummyQuestion() {
    return QuizQuestion(
      id: 0,
      description: "문제를 불러오는 중 오류가 발생했습니다.",
      imageUrl: "",
      options: [""],
      correctAnswerIndex: 0,
      hints: {},
    );
  }

  void selectHint(String hint) {
    if (!_viewedHints.contains(hint)) {
      _accumulatedHintCount++;
    }
    _selectedHint = hint;
    _showHintMessage = true;
    _viewedHints.add(hint);
    notifyListeners();

    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(seconds: 3), () {
      _showHintMessage = false;
      notifyListeners();
    });
  }

  void hideHintMessage() {
    _showHintMessage = false;
    _hintTimer?.cancel();
    notifyListeners();
  }

  void hideDescription() {
    _showDescription = false;
    _descriptionTimer?.cancel();
    notifyListeners();
  }

  void selectAnswer(int answerIndex) {
    if (_selectedAnswer != null) return;
    _selectedAnswer = answerIndex;
    _isCorrect = (answerIndex == currentQuestion.correctAnswerIndex);

    if (_isCorrect) {
      _correctCount++;
      _showDescription = true;
      _descriptionTimer?.cancel();
      _descriptionTimer = Timer(const Duration(seconds: 5), () {
        _showDescription = false;
        notifyListeners();
      });
    }

    // 학습 결과 큐에 추가
    ApiService.addPendingAttempt(<String, dynamic>{
      'tree_id': currentQuestion.id,
      'is_correct': _isCorrect,
      'user_answer': answerIndex,
      'time_taken_ms': 0,
      'mode': 'normal',
    });

    notifyListeners();
  }

  void nextQuestion() {
    if (hasNext) {
      _currentIndex++;
      _resetState();
      notifyListeners();
    }
  }

  void retry() {
    _resetState();
    notifyListeners();
  }

  void _resetState() {
    _selectedAnswer = null;
    _isCorrect = false;
    _showDescription = false;
    _showHintMessage = false;
    _selectedHint = '전체';
    _viewedHints.clear();
    _viewedHints.add('전체');
    _hintTimer?.cancel();
    _descriptionTimer?.cancel();
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _descriptionTimer?.cancel();
    super.dispose();
  }
}
