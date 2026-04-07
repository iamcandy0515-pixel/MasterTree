part of '../bulk_similar_management_viewmodel.dart';

/// Bulk Action Logic (Strategy: Domain Logic Part)
extension BulkActionLogic on BulkSimilarManagementViewModel {
  Future<void> runBulkRecommendation() async {
    final startIndex = (_currentPage - 1) * BulkSimilarManagementViewModel.itemsPerPage;
    final int endIndex = (startIndex + BulkSimilarManagementViewModel.itemsPerPage < _quizzes.length) ? startIndex + BulkSimilarManagementViewModel.itemsPerPage : _quizzes.length;
    final pageQuizzes = _quizzes.sublist(startIndex, endIndex);

    if (pageQuizzes.isEmpty) return;

    _isProcessing = true;
    _statusMessage = '현재 페이지 (5개) 분석을 시작합니다...';
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    notifyListeners();

    for (var quiz in pageQuizzes) {
      final quizId = quiz['id'] as int;
      _analysisStatus[quizId] = 1;
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      notifyListeners();

      final qText = getFullQuizText(quiz);
      if (qText.isNotEmpty) {
        try {
          final result = await _aiRepo.recommendRelated(questionText: qText, limit: 10);
          final filteredResult = (result).where((dynamic r) => r['id'] != quizId).toList();
          
          filteredResult.sort((dynamic a, dynamic b) {
            final int yA = (a as Map)['year'] as int? ?? 0;
            final int yB = (b as Map)['year'] as int? ?? 0;
            if (yA != yB) return yB.compareTo(yA);
            final int rA = (a as Map)['round'] as int? ?? 0;
            final int rB = (b as Map)['round'] as int? ?? 0;
            return rB.compareTo(rA);
          });

          _tempRecommendations[quizId] = List<Map<String, dynamic>>.from(filteredResult);
          _analysisStatus[quizId] = 2;
        } catch (e) {
          _analysisStatus[quizId] = 3;
        }
      } else {
        _analysisStatus[quizId] = 3;
      }
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      notifyListeners();
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }

    _isProcessing = false;
    _statusMessage = '현재 페이지 분석이 완료되었습니다.';
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    notifyListeners();
  }

  Future<void> saveAll() async {
    if (_tempRecommendations.isEmpty) return;

    _isProcessing = true;
    _statusMessage = '유사 문제를 일괄 저장 중...';
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
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
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      notifyListeners();
    }
  }

  void updateRecommendation(int quizId, List<Map<String, dynamic>> recs) {
    _tempRecommendations[quizId] = recs;
    _analysisStatus[quizId] = recs.isNotEmpty ? 2 : 0;
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    notifyListeners();
  }

  void setPage(int page) { 
    _currentPage = page; 
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    notifyListeners(); 
  }

  String getFullQuizText(Map<String, dynamic> quiz) {
    final blocks = quiz['content_blocks'] as List?;
    if (blocks == null || blocks.isEmpty) return '';
    return blocks.map((dynamic block) {
      if (block is Map<String, dynamic> && block['type'] == 'text') return block['content']?.toString() ?? '';
      return (block is String) ? block : '';
    }).where((text) => text.isNotEmpty).join('\n').trim();
  }
}
