part of '../bulk_similar_management_viewmodel.dart';

/// Bulk Filter & Fetching Logic (Strategy: Domain Logic Part)
extension BulkFilterLogic on BulkSimilarManagementViewModel {
  Future<void> loadSavedFilters() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedSubject = prefs.getString('sim_filter_subject');
    _selectedYear = prefs.getString('sim_filter_year');
    _selectedRound = prefs.getString('sim_filter_round');
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
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
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    notifyListeners();
  }

  void setYear(String? value) {
    _selectedYear = value;
    _saveFilters();
    _checkAndFetch();
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    notifyListeners();
  }

  void setRound(String? value) {
    _selectedRound = value;
    _saveFilters();
    _checkAndFetch();
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
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
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    notifyListeners();

    try {
      final supabase = Supabase.instance.client;
      final dynamic response = await supabase
          .from('quiz_questions')
          .select<PostgrestList>('*, quiz_exams!inner(year, round), quiz_categories!inner(name)')
          .eq('quiz_exams.year', int.parse(_selectedYear!))
          .eq('quiz_exams.round', int.parse(_selectedRound!))
          .like('quiz_categories.name', '%$_selectedSubject%')
          .order('question_number', ascending: true);

      _quizzes = List<Map<String, dynamic>>.from(response as List);
      for (var q in _quizzes) {
        final relatedIds = q['related_quiz_ids'] as List?;
        _analysisStatus[q['id'] as int] = (relatedIds != null && relatedIds.isNotEmpty) ? 2 : 0;
      }
      _statusMessage = '조회 완료: ${_quizzes.length}건';
    } catch (e) {
      _statusMessage = '조회 실패: $e';
    } finally {
      _isFetching = false;
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      notifyListeners();
    }
  }
}
