import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/api_service.dart';
import '../core/constants.dart';
import '../models/quiz_model.dart';

class QuizProvider extends ChangeNotifier {
  List<QuizQuestion> _questions = [];
  bool _isLoading = true;

  // Getters
  List<QuizQuestion> get questions => _questions;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  QuizQuestion get currentQuestion =>
      _questions.isNotEmpty ? _questions[_currentIndex] : _getDummyQuestion();

  // 힌트 관련
  String get selectedHint => _selectedHint;
  bool get showHintMessage => _showHintMessage;
  Set<String> get viewedHints => _viewedHints;
  int get viewedHintsCount => _viewedHints.length;
  String get currentHintText {
    final text = currentQuestion.hints[_selectedHint];
    if (text == null || text.trim().isEmpty || text == '정보 없음') {
      return '해당 힌트 정보가 없습니다.';
    }
    return text;
  }

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
  QuizRank get userRank {
    if (totalQuestions == 0) return QuizRank.sprout;
    final double avg = averageHints;
    if (avg <= 2.0) {
      return QuizRank.eagleEye;
    } else if (avg <= 4.0) {
      return QuizRank.forestKeeper;
    } else {
      return QuizRank.sprout;
    }
  }

  double get averageHints =>
      totalQuestions > 0 ? (_accumulatedHintCount / totalQuestions) : 0.0;

  QuizProvider() {
    _fetchQuestionsFromApi();
  }

  // API에서 데이터 가져오기
  Future<void> _fetchQuestionsFromApi() async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('${AppConstants.apiUrl}/trees?limit=100');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load trees from API: ${response.statusCode}',
        );
      }

      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] != true) {
        throw Exception('API error: ${jsonResponse['message']}');
      }

      final List<dynamic> data = jsonResponse['data'];
      List<QuizQuestion> loadedQuestions = [];

      if (data.isEmpty) {
        debugPrint('No trees found in DB.');
        _useDummyData(); // Fallback
        return;
      }

      // 2. QuizQuestion으로 변환 및 오답 보기 생성
      for (int i = 0; i < data.length; i++) {
        final tree = data[i];
        final String correctName = tree['name_kr'] as String;

        // 힌트 및 메인 이미지 파싱
        Map<String, String> hintsMap = {};
        String questionImageUrl = 'https://via.placeholder.com/400';

        final List<dynamic> images = tree['tree_images'] ?? [];

        for (var img in images) {
          final type = img['image_type'];
          final hint = img['hint'];
          final url = img['image_url'];

          // 이미지 선택 로직: main 우선, 없으면 첫 번째 유효한 이미지
          if (url != null && url.isNotEmpty) {
            if (type == 'main') {
              questionImageUrl = url;
            } else if (questionImageUrl.contains('placeholder')) {
              questionImageUrl = url;
            }
          }

          // 한글 키로 맵핑
          String? koreanKey;
          switch (type) {
            case 'main':
              koreanKey = '대표';
              if (url != null && url.isNotEmpty) questionImageUrl = url;
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

        // 필수 힌트가 없다면 기본값
        if (hintsMap.isEmpty) {
          hintsMap = {
            '잎': '정보 없음',
            '수피': '정보 없음',
            '꽃': '정보 없음',
            '열매/겨울눈': '정보 없음',
            '대표': '알 수 없음',
          };
        }

        // 3. 오답 보기 생성 (관리자 설정 오답 우선 사용)
        List<String> options = [correctName];
        final random = Random();

        final distractorData = tree['quiz_distractors'];
        List<String> manualDistractors = [];
        if (distractorData is List) {
          manualDistractors = distractorData
              .map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList();
        }

        if (manualDistractors.length >= 2) {
          // 관리자가 설정한 오답이 2개 이상이면 그것을 사용 (최대 2개만 채택하여 3지선다 유지)
          manualDistractors.shuffle(random);
          options.add(manualDistractors[0]);
          options.add(manualDistractors[1]);
        } else if (data.length >= 3) {
          // 데이터가 부족하거나 설정된 오답이 없으면 기존처럼 시스템 랜덤 추출 (Fallback)
          List<dynamic> otherTrees = List.from(data)..removeAt(i);
          otherTrees.shuffle(random);
          options.add(otherTrees[0]['name_kr'] as String);
          options.add(otherTrees[1]['name_kr'] as String);
        } else {
          // 최후의 수단: 더미 데이터
          options.add('다른나무1');
          options.add('다른나무2');
        }

        options.shuffle(random); // 보기 순서 섞기
        final int correctIndex = options.indexOf(correctName);

        loadedQuestions.add(
          QuizQuestion(
            id: tree['id'] is int
                ? tree['id']
                : int.tryParse(tree['id'].toString()) ?? 0,
            imageUrl: ApiService.getProxyImageUrl(questionImageUrl),
            description: tree['description'] ?? '설명이 없습니다.',
            correctAnswerIndex:
                correctIndex, // 0-based index for logic? QuizModel uses 0-based?
            // QuizQuestion definition in previous steps used 1-based,
            // BUT previous logic in selectAnswer used: (answerIndex == currentQuestion.correctAnswerIndex)
            // Let's assume we use 0-based index for options List.
            // CAUTION: Check if QuizQuestion expects 0 or 1 based index.
            // Looking at quiz_screen.dart: _buildOptions passes index 0,1,2.
            // So correctAnswerIndex should be 0,1,2.
            options: options,
            hints: hintsMap,
            // correctName 필드가 QuizQuestion 모델에 없으므로 제거
          ),
        );
      }

      // 4. 전체 문제 섞기
      loadedQuestions.shuffle();
      _questions = loadedQuestions;

      debugPrint('Loaded ${_questions.length} trees from DB.');
    } catch (e) {
      debugPrint('Error loading quiz data: $e');
      _useDummyData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _useDummyData() {
    // 하드코딩된 더미 데이터 (Hot Reload 문제 우회 및 데이터 보장)
    List<QuizQuestion> fallbackQuestions = [
      QuizQuestion(
        id: 1,
        description: '소나무는 한국을 대표하는 상록수로, 잎이 2개씩 뭉쳐나며 붉은빛이 도는 수피가 특징입니다.',
        imageUrl:
            'https://images.unsplash.com/photo-1542273917363-3b1817f69a2d?auto=format&fit=crop&q=80&w=800',
        options: ['소나무', '잣나무', '전나무'],
        correctAnswerIndex: 0,
        hints: {'잎': '2개씩 뭉쳐남', '수피': '붉은색 거북등', '대표': '애국가 소나무'},
      ),
      QuizQuestion(
        id: 2,
        description: '잣나무는 잎이 5개씩 뭉쳐나는 것이 특징입니다.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/Pinus_koraiensis_cone.jpg/800px-Pinus_koraiensis_cone.jpg',
        options: ['소나무', '잣나무', '편백나무'],
        correctAnswerIndex: 1,
        hints: {'잎': '5개씩 뭉쳐남', '수피': '흑갈색', '대표': '잣 열매'},
      ),
      QuizQuestion(
        id: 3,
        description: '가을에 노랗게 물드는 대표적인 가로수입니다.',
        imageUrl:
            'https://images.unsplash.com/photo-1507646549219-46766432098b?auto=format&fit=crop&q=80&w=800',
        options: ['단풍나무', '은행나무', '느티나무'],
        correctAnswerIndex: 1,
        hints: {'잎': '부채꼴 모양', '수피': '회색 세로 갈라짐', '대표': '살아있는 화석'},
      ),
      QuizQuestion(
        id: 4,
        description: '봄에 화려한 꽃을 피웁니다.',
        imageUrl: 'https://picsum.photos/seed/quiz3/400/400',
        options: ['벚나무', '매화나무', '살구나무'],
        correctAnswerIndex: 0,
        hints: {'잎': '톱니 있음', '수피': '가로 껍질눈', '꽃': '분홍색'},
      ),
      QuizQuestion(
        id: 5,
        description: '가을 단풍의 대명사입니다.',
        imageUrl: 'https://picsum.photos/seed/quiz5/400/400',
        options: ['신나무', '당단풍나무', '단풍나무'],
        correctAnswerIndex: 2,
        hints: {'잎': '손바닥 모양', '수피': '매끈함', '대표': '가을 붉은 잎'},
      ),
    ];

    _questions = List.from(fallbackQuestions)..shuffle();
    debugPrint('Using HARDCODED dummy data (${_questions.length} items)');
  }

  // 안전 장치: 데이터가 없을 때
  QuizQuestion _getDummyQuestion() {
    return QuizQuestion(
      id: 0,
      imageUrl: '',
      description: '로딩 중...',
      correctAnswerIndex: 0,
      options: ['Loading...'],
      hints: {},
    );
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
