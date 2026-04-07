import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_user_app/repositories/exam_repository.dart';
import 'package:flutter_user_app/utils/exam_data_utility.dart';
import 'mixins/exam_filter_mixin.dart';
import 'mixins/exam_pagination_mixin.dart';
import 'mixins/exam_persistence_mixin.dart';

class PastExamListController with ExamFilterMixin, ExamPaginationMixin, ExamPersistenceMixin {
  final ExamRepository _repository = ExamRepository();
  bool isLoading = false;
  bool hasSearched = false;
  List<Map<String, dynamic>> quizzes = [];
  Timer? _debounce;

  Future<void> fetchQuizzes({
    required VoidCallback onUpdate,
    required Function(String) onError,
  }) async {
    isLoading = true;
    hasSearched = true;
    onUpdate();

    try {
      // Calculate data range for pagination
      const perPage = ExamPaginationMixin.itemsPerPage;
      final from = (currentPage - 1) * perPage;
      final to = from + perPage - 1;

      final Map<String, dynamic> result = await _repository.fetchQuestions(
        subject: selectedSubject,
        year: selectedYear,
        session: selectedSession,
        from: from,
        to: to,
      );

      quizzes = List<Map<String, dynamic>>.from(result['questions'] as List);
      totalResults = result['totalItems'] as int;
      totalPages = (totalResults / perPage).ceil();
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
    final filters = await loadSavedFiltersData();
    selectedSubject = filters['subject'];
    selectedYear = filters['year'];
    selectedSession = filters['session'];

    if (isFilterComplete) {
      firstPagePrimitive();
      await fetchQuizzes(onUpdate: onUpdate, onError: onError);
    } else {
      onUpdate();
    }
  }

  void _onFilterChanged({
    required VoidCallback onUpdate,
    required Function(String) onError,
  }) {
    saveFilters(
      subject: selectedSubject,
      year: selectedYear,
      session: selectedSession,
    );

    if (isFilterComplete) {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        firstPagePrimitive();
        fetchQuizzes(onUpdate: onUpdate, onError: onError);
      });
    } else {
      onUpdate();
    }
  }

  // Filter Setters
  void setSubject(String? val, {required VoidCallback onUpdate, required Function(String) onError}) {
    selectedSubject = val;
    _onFilterChanged(onUpdate: onUpdate, onError: onError);
  }

  void setYear(String? val, {required VoidCallback onUpdate, required Function(String) onError}) {
    selectedYear = val;
    _onFilterChanged(onUpdate: onUpdate, onError: onError);
  }

  void setSession(String? val, {required VoidCallback onUpdate, required Function(String) onError}) {
    selectedSession = val;
    _onFilterChanged(onUpdate: onUpdate, onError: onError);
  }

  // Pagination Wrappers (Matches original controller signature for UI compatibility)
  void nextPage({required VoidCallback onUpdate, required Function(String) onError}) {
    if (currentPage < totalPages) {
      nextPagePrimitive();
      fetchQuizzes(onUpdate: onUpdate, onError: onError);
    }
  }

  void prevPage({required VoidCallback onUpdate, required Function(String) onError}) {
    if (currentPage > 1) {
      prevPagePrimitive();
      fetchQuizzes(onUpdate: onUpdate, onError: onError);
    }
  }

  void firstPage({required VoidCallback onUpdate, required Function(String) onError}) {
    if (currentPage != 1) {
      firstPagePrimitive();
      fetchQuizzes(onUpdate: onUpdate, onError: onError);
    }
  }

  void lastPage({required VoidCallback onUpdate, required Function(String) onError}) {
    if (currentPage != totalPages) {
      lastPagePrimitive();
      fetchQuizzes(onUpdate: onUpdate, onError: onError);
    }
  }

  String extractQuestionText(Map<String, dynamic> quiz) => ExamDataUtility.extractQuestionText(quiz);

  void dispose() {
    _debounce?.cancel();
  }
}
