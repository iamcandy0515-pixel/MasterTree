import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/fallback_quiz_data.dart';
import '../models/quiz_model.dart';
import '../repositories/quiz_repository.dart';

class QuizProvider extends ChangeNotifier {
  List<QuizQuestion> _questions = [];
  bool _isLoading = true;

  // Getters
  List<QuizQuestion> get questions => _questions;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  QuizQuestion get currentQuestion =>
      _questions.isNotEmpty ? _questions[_currentIndex] : QuizRepository.getDummyQuestion();

  // 힌트 관련
  String get selectedHint => _selectedHint;
  bool get showHintMessage => _showHintMessage;
  Set<String> get viewedHints => _viewedHints;
  int get viewedHintsCount => _viewedHints.length;
  String get currentHintText => currentQuestion.getHintText(_selectedHint);

  // 답변 관련
  int? get selectedAnswer => _selectedAnswer;
  bool get isCorrect => _isCorrect;
  bool get showDescription => _showDescription;

  // 통계
  int get correctCount => _correctCount;
  int get accumulatedHintCount => _accumulatedHintCount;

  // 현재까지 푼 문제 수 (정답/오답 상관없이)
  int get solvedCount =>
      _selectedAnswer != null ? _currentIndex + 1 : _currentIndex;

  // 전체 문제 수를 DB 데이터 기반으로 반환
  int get totalQuestions => _questions.length;
  bool get hasNext => _currentIndex < _questions.length - 1;

  // 결과 등급 계산
  QuizRank get userRank => QuizRankHelper.fromAverage(averageHints);
  String get userRankName => QuizRankHelper.getName(userRank);

  double get averageHints =>
      totalQuestions > 0 ? (_accumulatedHintCount / totalQuestions) : 0.0;

  QuizProvider() {
    loadQuestions();
  }

  // 데이터 로드
  Future<void> loadQuestions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final loadedQuestions = await QuizRepository.fetchQuestions();
      if (loadedQuestions.isEmpty) {
        _useDummyData();
      } else {
        loadedQuestions.shuffle();
        _questions = loadedQuestions;
        debugPrint('Loaded ${_questions.length} questions from Repository.');
      }
    } catch (e) {
      debugPrint('Error loading quiz data via repository: $e');
      _useDummyData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _useDummyData() {
    _questions = getFallbackQuizQuestions()..shuffle();
    debugPrint('Using fallback dummy data (${_questions.length} items)');
  }

  int _currentIndex = 0;

  // 힌트 상태
  String _selectedHint = '대표';
  final Set<String> _viewedHints = {'대표'};
  bool _showHintMessage = false;
  Timer? _hintTimer;

  // 답변 상태
  int? _selectedAnswer;
  bool _isCorrect = false;
  bool _showDescription = false;
  Timer? _descriptionTimer;

  // 통계
  int _correctCount = 0;
  int _accumulatedHintCount = 0;

  // Actions
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
    notifyListeners();
  }

  void nextQuestion() {
    if (hasNext) {
      _currentIndex++;
      _resetState();
      notifyListeners();
      debugPrint('Next question: $_currentIndex / ${_questions.length}');
    }
  }

  void restartQuiz() {
    _currentIndex = 0;
    _correctCount = 0;
    _accumulatedHintCount = 0;
    _questions.shuffle(); // 순서 다시 섞기
    _resetState();
    notifyListeners();
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

    _selectedHint = '대표';
    _viewedHints.clear();
    _viewedHints.add('대표');

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
