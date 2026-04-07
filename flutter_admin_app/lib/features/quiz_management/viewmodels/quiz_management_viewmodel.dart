import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/quiz_repository.dart';

class QuizManagementViewModel extends ChangeNotifier {
  final _quizRepo = QuizRepository();

  // State
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _error;
  List<Map<String, dynamic>> _quizzes = [];
  
  // Search Filters
  String? _selectedSubject;
  String? _selectedYear;
  String? _selectedSession;

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  static const int _itemsPerPage = 5;

  // Constants (Managed in ViewModel as requested)
  final List<String> subjects = [
    '산림기사',
    '산림산업기사',
    '산업안전기사',
    '산업안전산업기사',
    '조경기사',
    '조경산업기사',
  ];
  
  final List<String> years = List.generate(
    14,
    (index) => (2013 + index).toString(),
  );
  
  final List<String> sessions = ['1', '2', '3', '4'];

  // Getters
  bool get isLoading => _isLoading;
  bool get hasSearched => _hasSearched;
  String? get error => _error;
  List<Map<String, dynamic>> get quizzes => _quizzes;
  String? get selectedSubject => _selectedSubject;
  String? get selectedYear => _selectedYear;
  String? get selectedSession => _selectedSession;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  // Setters with Auto-fetch
  void setSubject(String? value) {
    _selectedSubject = value;
    _currentPage = 1;
    _autoFetch();
    notifyListeners();
  }

  void setYear(String? value) {
    _selectedYear = value;
    _currentPage = 1;
    _autoFetch();
    notifyListeners();
  }

  void setSession(String? value) {
    _selectedSession = value;
    _currentPage = 1;
    _autoFetch();
    notifyListeners();
  }

  void _autoFetch() {
    if (_selectedSubject != null && _selectedYear != null && _selectedSession != null) {
      fetchQuizzes();
    }
  }

  void setPage(int page) {
    if (page < 1 || page > _totalPages) return;
    _currentPage = page;
    fetchQuizzes();
  }

  Future<void> fetchQuizzes() async {
    if (_selectedSubject == null || _selectedYear == null || _selectedSession == null) {
      _error = '조회 조건(과목명, 년도, 회차)을 모두 선택해주세요.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _hasSearched = true;
    _error = null;
    notifyListeners();

    try {
      final supabase = Supabase.instance.client;

      var baseQuery = supabase.from('quiz_questions').select<PostgrestList>('''
        *,
        quiz_exams!inner(year, round, title),
        quiz_categories!inner(name)
      ''');

      baseQuery = baseQuery.like('quiz_categories.name', '%$_selectedSubject%');
      baseQuery = baseQuery.eq('quiz_exams.year', int.parse(_selectedYear!));
      baseQuery = baseQuery.eq('quiz_exams.round', int.parse(_selectedSession!));

      final from = (_currentPage - 1) * _itemsPerPage;
      final to = from + _itemsPerPage - 1;

      final dynamic response = await baseQuery
          .order('question_number', ascending: true)
          .range(from, to)
          .timeout(const Duration(seconds: 15));

      // Count calculation
      final dynamic allIds = await supabase
          .from('quiz_questions')
          .select<PostgrestList>('id, quiz_exams!inner(year, round), quiz_categories!inner(name)')
          .like('quiz_categories.name', '%$_selectedSubject%')
          .eq('quiz_exams.year', int.parse(_selectedYear!))
          .eq('quiz_exams.round', int.parse(_selectedSession!));

      final totalItems = (allIds as List).length;
      _quizzes = List<Map<String, dynamic>>.from(response as List);
      _totalPages = (totalItems / _itemsPerPage).ceil();
      if (_totalPages == 0) _totalPages = 1;

    } catch (e) {
      _error = '데이터를 불러오는데 실패했습니다: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteQuiz(int id) async {
    try {
      await _quizRepo.deleteQuiz(id);
      await fetchQuizzes();
    } catch (e) {
      _error = '삭제 실패: $e';
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
