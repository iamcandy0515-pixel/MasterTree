import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PastExamListController {
  String? selectedSubject;
  String? selectedYear;
  String? selectedSession;

  Timer? _debounce;

  bool get isFilterComplete =>
      selectedSubject != null &&
      selectedYear != null &&
      selectedSession != null;

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
  final List<String> sessions = ['1', '2', '3'];

  bool isLoading = false;
  List<Map<String, dynamic>> quizzes = [];

  int currentPage = 1;
  int totalPages = 1;
  int totalResults = 0;
  static const int itemsPerPage = 5;

  bool hasSearched = false;

  Future<void> fetchQuizzes({
    required VoidCallback onUpdate,
    required Function(String) onError,
  }) async {
    isLoading = true;
    hasSearched = true;
    onUpdate();

    try {
      final supabase = Supabase.instance.client;

      var baseQuery = supabase.from('quiz_questions').select('''
        *,
        quiz_exams!inner(year, round, title),
        quiz_categories!inner(name)
      ''');

      if (selectedSubject != null) {
        baseQuery = baseQuery.like(
          'quiz_categories.name',
          '%$selectedSubject%',
        );
      }
      if (selectedYear != null) {
        baseQuery = baseQuery.eq('quiz_exams.year', int.parse(selectedYear!));
      }
      if (selectedSession != null) {
        baseQuery = baseQuery.eq(
          'quiz_exams.round',
          int.parse(selectedSession!),
        );
      }

      final from = (currentPage - 1) * itemsPerPage;
      final to = from + itemsPerPage - 1;

      final dataQuery = baseQuery
          .order('question_number', ascending: true)
          .range(from, to);
      final response = await dataQuery;

      // Count calculation
      var countQuery = supabase
          .from('quiz_questions')
          .select(
            'id, quiz_exams!inner(year, round), quiz_categories!inner(name)',
          );
      if (selectedSubject != null) {
        countQuery = countQuery.like(
          'quiz_categories.name',
          '%$selectedSubject%',
        );
      }
      if (selectedYear != null) {
        countQuery = countQuery.eq('quiz_exams.year', int.parse(selectedYear!));
      }
      if (selectedSession != null) {
        countQuery = countQuery.eq(
          'quiz_exams.round',
          int.parse(selectedSession!),
        );
      }

      final allIds = await countQuery;
      final totalItems = (allIds as List).length;

      quizzes = List<Map<String, dynamic>>.from(response);
      totalResults = totalItems;
      totalPages = (totalItems / itemsPerPage).ceil();
      if (totalPages == 0) totalPages = 1;

      isLoading = false;
    } catch (e) {
      debugPrint('Error fetching quizzes: $e');
      isLoading = false;
      onError(e.toString());
    } finally {
      onUpdate();
    }
  }

  Future<void> loadSavedFilters({
    required VoidCallback onUpdate,
    required Function(String) onError,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    selectedSubject = prefs.getString('user_exam_subject');
    selectedYear = prefs.getString('user_exam_year');
    selectedSession = prefs.getString('user_exam_session');

    if (isFilterComplete) {
      currentPage = 1;
      await fetchQuizzes(onUpdate: onUpdate, onError: onError);
    } else {
      onUpdate();
    }
  }

  Future<void> _saveFilters() async {
    final prefs = await SharedPreferences.getInstance();
    if (selectedSubject != null) {
      await prefs.setString('user_exam_subject', selectedSubject!);
    }
    if (selectedYear != null) {
      await prefs.setString('user_exam_year', selectedYear!);
    }
    if (selectedSession != null) {
      await prefs.setString('user_exam_session', selectedSession!);
    }
  }

  void _onFilterChanged({
    required VoidCallback onUpdate,
    required Function(String) onError,
  }) {
    _saveFilters();
    if (isFilterComplete) {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        currentPage = 1;
        fetchQuizzes(onUpdate: onUpdate, onError: onError);
      });
    } else {
      onUpdate();
    }
  }

  void setSubject(
    String? val, {
    required VoidCallback onUpdate,
    required Function(String) onError,
  }) {
    selectedSubject = val;
    _onFilterChanged(onUpdate: onUpdate, onError: onError);
  }

  void setYear(
    String? val, {
    required VoidCallback onUpdate,
    required Function(String) onError,
  }) {
    selectedYear = val;
    _onFilterChanged(onUpdate: onUpdate, onError: onError);
  }

  void setSession(
    String? val, {
    required VoidCallback onUpdate,
    required Function(String) onError,
  }) {
    selectedSession = val;
    _onFilterChanged(onUpdate: onUpdate, onError: onError);
  }

  void nextPage({
    required VoidCallback onUpdate,
    required Function(String) onError,
  }) {
    if (currentPage < totalPages) {
      currentPage++;
      fetchQuizzes(onUpdate: onUpdate, onError: onError);
    }
  }

  void prevPage({
    required VoidCallback onUpdate,
    required Function(String) onError,
  }) {
    if (currentPage > 1) {
      currentPage--;
      fetchQuizzes(onUpdate: onUpdate, onError: onError);
    }
  }

  void firstPage({
    required VoidCallback onUpdate,
    required Function(String) onError,
  }) {
    if (currentPage != 1) {
      currentPage = 1;
      fetchQuizzes(onUpdate: onUpdate, onError: onError);
    }
  }

  void lastPage({
    required VoidCallback onUpdate,
    required Function(String) onError,
  }) {
    if (currentPage != totalPages) {
      currentPage = totalPages;
      fetchQuizzes(onUpdate: onUpdate, onError: onError);
    }
  }

  String extractQuestionText(Map<String, dynamic> quiz) {
    String qText = '문제 내용 없음';
    try {
      final blocks = quiz['content_blocks'] as List<dynamic>;
      if (blocks.isNotEmpty) {
        qText = blocks[0]['content'] as String;
      }
    } catch (_) {}

    final qNum = quiz['question_number'];
    if (qNum != null) {
      // 문제번호(qNum)와 같은 숫자 두자리수가 qText 시작 부분에 있으면 제거
      final String qNumStr = qNum.toString().padLeft(2, '0');
      if (qText.startsWith(qNumStr)) {
        qText = qText.substring(qNumStr.length).trim();
      }
      return '$qNum번. $qText';
    }
    return qText;
  }
}
