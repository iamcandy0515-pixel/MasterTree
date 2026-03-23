import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/quiz_repository.dart';
import '../repositories/quiz_ai_repository.dart';

class BulkSimilarManagementViewModel extends ChangeNotifier {
  final QuizRepository _quizRepo = QuizRepository();
  final QuizAiRepository _aiRepo = QuizAiRepository();
  
  List<Map<String, dynamic>> _quizzes = [];
  Map<int, List<Map<String, dynamic>>> _tempRecommendations = {};
  final Map<int, int> _analysisStatus = {}; // 0:대기, 1:분석중, 2:완료, 3:실패
  String? _selectedSubject, _selectedYear, _selectedRound;
  bool _isFetching = false, _isProcessing = false;
  String _statusMessage = '';
  int _currentPage = 1;
  static const int itemsPerPage = 5;

  List<Map<String, dynamic>> get quizzes => _quizzes;
  Map<int, List<Map<String, dynamic>>> get tempRecommendations => _tempRecommendations;
  Map<int, int> get analysisStatus => _analysisStatus;
  String? get selectedSubject => _selectedSubject;
  String? get selectedYear => _selectedYear;
  String? get selectedRound => _selectedRound;
  bool get isFetching => _isFetching;
  bool get isProcessing => _isProcessing;
  String get statusMessage => _statusMessage;
  int get currentPage => _currentPage;
  int get totalPages => (_quizzes.length / itemsPerPage).ceil();

  final List<String> subjects = ['산림기사', '산림산업기사', '산업안전기사', '산업안전산업기사', '조경기사', '조경산업기사'];
  final List<String> years = List.generate(14, (i) => (2013 + i).toString());
  final List<String> rounds = ['1', '2', '3', '4'];

  Future<void> loadSavedFilters() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedSubject = prefs.getString('sim_filter_subject');
    _selectedYear = prefs.getString('sim_filter_year');
    _selectedRound = prefs.getString('sim_filter_round');
    notifyListeners();

    if (_selectedSubject != null && _selectedYear != null && _selectedRound != null) {
      await fetchQuizzes();
    }
  }

  Future<void> _saveFilters() async {
    final prefs = await SharedPreferences.getInstance();
    if (_selectedSubject != null) await prefs.setString('sim_filter_subject', _selectedSubject!);
    if (_selectedYear != null) await prefs.setString('sim_filter_year', _selectedYear!);
    if (_selectedRound != null) await prefs.setString('sim_filter_round', _selectedRound!);
  }

  void setSubject(String? value) {
    _selectedSubject = value;
    _saveFilters();
    _checkAndFetch();
    notifyListeners();
  }

  void setYear(String? value) {
    _selectedYear = value;
    _saveFilters();
    _checkAndFetch();
    notifyListeners();
  }

  void setRound(String? value) {
    _selectedRound = value;
    _saveFilters();
    _checkAndFetch();
    notifyListeners();
  }

  void _checkAndFetch() {
    if (_selectedSubject != null && _selectedYear != null && _selectedRound != null) {
      fetchQuizzes();
    }
  }

  Future<void> fetchQuizzes() async {
    _isFetching = true;
    _quizzes = [];
    _tempRecommendations = {};
    _analysisStatus.clear();
    _currentPage = 1;
    _statusMessage = '문제를 불러오는 중...';
    notifyListeners();

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('quiz_questions')
          .select('*, quiz_exams!inner(year, round), quiz_categories!inner(name)')
          .eq('quiz_exams.year', int.parse(_selectedYear!))
          .eq('quiz_exams.round', int.parse(_selectedRound!))
          .like('quiz_categories.name', '%$_selectedSubject%')
          .order('question_number', ascending: true);

      _quizzes = List<Map<String, dynamic>>.from(response);
      for (var q in _quizzes) {
        final relatedIds = q['related_quiz_ids'] as List?;
        _analysisStatus[q['id'] as int] = (relatedIds != null && relatedIds.isNotEmpty) ? 2 : 0;
      }
      _statusMessage = '조회 완료: ${_quizzes.length}건';
    } catch (e) {
      _statusMessage = '조회 실패: $e';
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  Future<void> runBulkRecommendation() async {
    final startIndex = (_currentPage - 1) * itemsPerPage;
    final int endIndex = (startIndex + itemsPerPage < _quizzes.length) ? startIndex + itemsPerPage : _quizzes.length;
    final pageQuizzes = _quizzes.sublist(startIndex, endIndex);

    if (pageQuizzes.isEmpty) return;

    _isProcessing = true;
    _statusMessage = '현재 페이지 (5개) 분석을 시작합니다...';
    notifyListeners();

    for (var quiz in pageQuizzes) {
      final quizId = quiz['id'] as int;
      _analysisStatus[quizId] = 1;
      notifyListeners();

      final qText = getFullQuizText(quiz);
      if (qText.isNotEmpty) {
        try {
          final result = await _aiRepo.recommendRelated(questionText: qText, limit: 10);
          final filteredResult = (result).where((r) => r['id'] != quizId).toList();
          
          filteredResult.sort((a, b) {
            final yA = a['year'] ?? 0;
            final yB = b['year'] ?? 0;
            if (yA != yB) return yB.compareTo(yA);
            return (b['round'] ?? 0).compareTo(a['round'] ?? 0);
          });

          _tempRecommendations[quizId] = List<Map<String, dynamic>>.from(filteredResult);
          _analysisStatus[quizId] = 2;
        } catch (e) {
          _analysisStatus[quizId] = 3;
        }
      } else {
        _analysisStatus[quizId] = 3;
      }
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 300));
    }

    _isProcessing = false;
    _statusMessage = '현재 페이지 분석이 완료되었습니다.';
    notifyListeners();
  }

  Future<void> saveAll() async {
    if (_tempRecommendations.isEmpty) return;

    _isProcessing = true;
    _statusMessage = '유사 문제를 일괄 저장 중...';
    notifyListeners();

    try {
      final relatedMap = _tempRecommendations.map((key, value) {
        return MapEntry(key, value.map((v) => v['id'] as int).toList());
      });

      await _quizRepo.upsertRelatedBulk(relatedMap);
      _tempRecommendations = {};
      _statusMessage = '저장 완료';
      await fetchQuizzes();
    } catch (e) {
      _statusMessage = '저장 실패: $e';
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void updateRecommendation(int quizId, List<Map<String, dynamic>> recs) {
    _tempRecommendations[quizId] = recs;
    _analysisStatus[quizId] = recs.isNotEmpty ? 2 : 0;
    notifyListeners();
  }

  void setPage(int page) { _currentPage = page; notifyListeners(); }

  String getFullQuizText(Map<String, dynamic> quiz) {
    final blocks = quiz['content_blocks'] as List?;
    if (blocks == null || blocks.isEmpty) return '';
    return blocks.map((block) {
      if (block is Map<String, dynamic> && block['type'] == 'text') return block['content']?.toString() ?? '';
      return (block is String) ? block : '';
    }).where((text) => text.isNotEmpty).join('\n').trim();
  }
}
