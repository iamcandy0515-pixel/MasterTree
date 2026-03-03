import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../models/quiz_model.dart';

class QuizController {
  List<QuizQuestion> _questions = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  String _selectedHint = '대표';
  final Set<String> _viewedHints = {'대표'};
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

  Future<void> initialize(VoidCallback onUpdate) async {
    await _fetchQuestionsFromApi(onUpdate);
  }

  Future<void> _fetchQuestionsFromApi(VoidCallback onUpdate) async {
    _isLoading = true;
    onUpdate();

    try {
      final List<Map<String, dynamic>> data = await ApiService.getTrees(
        limit: 100,
      );
      if (data.isNotEmpty) {
        _processData(data);
      } else {
        _useDummyData();
      }
    } catch (e) {
      _useDummyData();
    } finally {
      _isLoading = false;
      onUpdate();
    }
  }

  void _processData(List<dynamic> data) {
    List<QuizQuestion> loadedQuestions = [];
    final random = Random();

    for (int i = 0; i < data.length; i++) {
      final tree = data[i];
      final String correctName = tree['name_kr'] as String;
      Map<String, String> hintsMap = {};
      String questionImageUrl = '';

      final List<dynamic> images = tree['tree_images'] ?? [];
      for (var img in images) {
        final type = img['image_type'];
        final hint = img['hint'];
        final url = img['image_url'];

        if (url != null && url.isNotEmpty) {
          if (type == 'main' || questionImageUrl.isEmpty) {
            questionImageUrl = url;
          }
        }

        String? koreanKey;
        switch (type) {
          case 'main':
            koreanKey = '대표';
            break;
          case 'leaf':
            koreanKey = '잎';
            break;
          case 'bark':
            koreanKey = '수피';
            break;
          case 'flower':
            koreanKey = '꽃';
            break;
          case 'fruit':
            koreanKey = '열매/겨울눈';
            break;
        }

        if (koreanKey != null &&
            hint != null &&
            hint.toString().trim().isNotEmpty) {
          hintsMap[koreanKey] = hint.toString();
        }
      }

      List<String> options = [correctName];
      final distractorData = tree['quiz_distractors'];
      if (distractorData is List && distractorData.isNotEmpty) {
        List<String> manual = distractorData.map((e) => e.toString()).toList();
        manual.shuffle(random);
        options.addAll(manual.take(2));
      } else {
        List<dynamic> others = List.from(data)..removeAt(i);
        others.shuffle(random);
        if (others.length >= 2) {
          options.add(others[0]['name_kr']);
          options.add(others[1]['name_kr']);
        }
      }

      while (options.length < 3) {
        options.add('다른 나무 ${options.length}');
      }

      options.shuffle(random);
      loadedQuestions.add(
        QuizQuestion(
          id: tree['id'] is int
              ? tree['id']
              : int.tryParse(tree['id'].toString()) ?? 0,
          imageUrl: ApiService.getProxyImageUrl(questionImageUrl),
          description: tree['description'] ?? '설명이 없습니다.',
          correctAnswerIndex: options.indexOf(correctName),
          options: options,
          hints: hintsMap,
        ),
      );
    }

    loadedQuestions.shuffle();
    _questions = loadedQuestions;
  }

  void _useDummyData() {
    _questions = [
      QuizQuestion(
        id: 1,
        description: '소나무는 한국을 대표하는 상록수로, 잎이 2개씩 뭉쳐나며 붉은빛이 도는 수피가 특징입니다.',
        imageUrl:
            'https://images.unsplash.com/photo-1542273917363-3b1817f69a2d?auto=format&fit=crop&q=80&w=800',
        options: ['소나무', '잣나무', '전나무'],
        correctAnswerIndex: 0,
        hints: {'잎': '2개씩 뭉쳐남', '수피': '붉은색 거북등', '대표': '애국가 소나무'},
      ),
    ];
  }

  QuizQuestion _getDummyQuestion() {
    return QuizQuestion(
      id: 0,
      imageUrl: '',
      description: '',
      correctAnswerIndex: 0,
      options: [''],
      hints: {},
    );
  }

  void selectHint(String hint, VoidCallback onUpdate) {
    if (!_viewedHints.contains(hint)) {
      _accumulatedHintCount++;
    }
    _selectedHint = hint;
    _showHintMessage = true;
    _viewedHints.add(hint);
    onUpdate();

    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(seconds: 3), () {
      _showHintMessage = false;
      onUpdate();
    });
  }

  void hideHintMessage(VoidCallback onUpdate) {
    _showHintMessage = false;
    _hintTimer?.cancel();
    onUpdate();
  }

  void hideDescription(VoidCallback onUpdate) {
    _showDescription = false;
    _descriptionTimer?.cancel();
    onUpdate();
  }

  void selectAnswer(int answerIndex, VoidCallback onUpdate) {
    if (_selectedAnswer != null) return;
    _selectedAnswer = answerIndex;
    _isCorrect = (answerIndex == currentQuestion.correctAnswerIndex);

    if (_isCorrect) {
      _correctCount++;
      _showDescription = true;
      _descriptionTimer?.cancel();
      _descriptionTimer = Timer(const Duration(seconds: 5), () {
        _showDescription = false;
        onUpdate();
      });
    }

    // 학습 결과 큐에 추가 (배치 전송을 위해 보관)
    ApiService.addPendingAttempt({
      'question_id': currentQuestion.id,
      'is_correct': _isCorrect,
      'user_answer': answerIndex,
      'time_taken_ms': 0, // 나중에 측정 로직 추가 가능
    });

    onUpdate();
  }

  void nextQuestion(VoidCallback onUpdate) {
    if (hasNext) {
      _currentIndex++;
      _resetState();
      onUpdate();
    }
  }

  void retry(VoidCallback onUpdate) {
    _resetState();
    onUpdate();
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

  void dispose() {
    _hintTimer?.cancel();
    _descriptionTimer?.cancel();
  }
}
