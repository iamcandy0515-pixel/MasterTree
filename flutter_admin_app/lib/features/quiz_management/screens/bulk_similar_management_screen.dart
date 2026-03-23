import 'package:flutter/material.dart';
import '../viewmodels/bulk_similar_management_viewmodel.dart';
import 'widgets/similar_quiz_review_dialog.dart';
import 'widgets/bulk/bulk_filter_panel.dart';
import 'widgets/bulk/bulk_action_header.dart';
import 'widgets/bulk/bulk_pagination_bar.dart';
import 'widgets/bulk/bulk_quiz_list_item.dart';
import '../repositories/quiz_repository.dart';

class BulkSimilarManagementScreen extends StatefulWidget {
  const BulkSimilarManagementScreen({super.key});

  @override
  State<BulkSimilarManagementScreen> createState() => _BulkSimilarManagementScreenState();
}

class _BulkSimilarManagementScreenState extends State<BulkSimilarManagementScreen> {
  final BulkSimilarManagementViewModel _viewModel = BulkSimilarManagementViewModel();
  final QuizRepository _quizRepo = QuizRepository();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelUpdate);
    _viewModel.loadSavedFilters();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelUpdate);
    super.dispose();
  }

  void _onViewModelUpdate() {
    if (mounted) setState(() {});
  }

  void _showReviewDialog(Map<String, dynamic> quiz) {
    showDialog(
      context: context,
      builder: (context) => SimilarQuizReviewDialog(
        quiz: quiz,
        selectedYear: _viewModel.selectedYear,
        selectedRound: _viewModel.selectedRound,
        initialRecommendations: _viewModel.tempRecommendations[quiz['id']] ?? [],
        quizRepo: _quizRepo,
        onUpdate: (updatedRecommendations) => _viewModel.updateRecommendation(quiz['id'] as int, updatedRecommendations),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const backgroundDark = Color(0xFF102219);
    
    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        backgroundColor: backgroundDark,
        title: const Text('기출문제 유사문제 추출(일괄)', style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: Column(
        children: [
          BulkActionHeader(
            isProcessing: _viewModel.isProcessing,
            isEmpty: _viewModel.quizzes.isEmpty,
            hasRecommendations: _viewModel.tempRecommendations.isNotEmpty,
            onBulkRecommend: _viewModel.runBulkRecommendation,
            onSaveAll: _viewModel.saveAll,
          ),
          BulkFilterPanel(
            selectedSubject: _viewModel.selectedSubject,
            selectedYear: _viewModel.selectedYear,
            selectedRound: _viewModel.selectedRound,
            subjects: _viewModel.subjects,
            years: _viewModel.years,
            rounds: _viewModel.rounds,
            statusMessage: _viewModel.statusMessage,
            onSubjectChanged: _viewModel.setSubject,
            onYearChanged: _viewModel.setYear,
            onRoundChanged: _viewModel.setRound,
          ),
          BulkPaginationBar(
            currentPage: _viewModel.currentPage,
            totalPages: _viewModel.totalPages,
            onPageChanged: _viewModel.setPage,
          ),
          Expanded(child: _buildQuizList()),
        ],
      ),
    );
  }

  Widget _buildQuizList() {
    if (_viewModel.isFetching) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF2BEE8C)));
    }
    if (_viewModel.quizzes.isEmpty) {
      return const Center(child: Text('조회된 문제가 없습니다.', style: TextStyle(color: Colors.grey)));
    }

    final startIndex = (_viewModel.currentPage - 1) * BulkSimilarManagementViewModel.itemsPerPage;
    final int endIndex = (startIndex + BulkSimilarManagementViewModel.itemsPerPage < _viewModel.quizzes.length)
        ? startIndex + BulkSimilarManagementViewModel.itemsPerPage
        : _viewModel.quizzes.length;
    final pageQuizzes = _viewModel.quizzes.sublist(startIndex, endIndex);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      itemCount: pageQuizzes.length,
      itemBuilder: (context, index) {
        final quiz = pageQuizzes[index];
        final id = quiz['id'] as int;
        return BulkQuizListItem.build(
          quiz: quiz,
          fullText: _viewModel.getFullQuizText(quiz),
          status: _viewModel.analysisStatus[id] ?? 0,
          displayCount: _getDisplayCount(quiz, id),
          onTap: () => _showReviewDialog(quiz),
        );
      },
    );
  }

  int _getDisplayCount(Map<String, dynamic> quiz, int id) {
    final recs = _viewModel.tempRecommendations[id] ?? [];
    final storedCount = (quiz['related_quiz_ids'] as List?)?.length ?? 0;
    return recs.length > storedCount ? recs.length : storedCount;
  }
}
