import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../viewmodels/bulk_similar_management_viewmodel.dart';
import '../bulk_quiz_list_item.dart';
import '../../similar_quiz_review_dialog.dart';
import '../../../../repositories/quiz_repository.dart';

/// Bulk Quiz List View (Strategy: Virtualization & Isolated Rebuild)
/// 리스트 영역만 독립적으로 리빌드되도록 분리하여 전체 화면 성능 최적화.
class BulkQuizListView extends StatelessWidget {
  final QuizRepository quizRepo;
  const BulkQuizListView({super.key, required this.quizRepo});

  @override
  Widget build(BuildContext context) {
    return Selector<BulkSimilarManagementViewModel, bool>(
      selector: (_, vm) => vm.isFetching,
      builder: (context, isFetching, child) {
        if (isFetching) return const Center(child: CircularProgressIndicator(color: Color(0xFF2BEE8C)));
        return child!;
      },
      child: Consumer<BulkSimilarManagementViewModel>(
        builder: (context, vm, _) {
          final pageQuizzes = vm.getCurrentPageQuizzes();
          if (pageQuizzes.isEmpty) return const Center(child: Text('조회된 문제가 없습니다.', style: TextStyle(color: Colors.grey)));

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: pageQuizzes.length,
            itemBuilder: (context, index) {
              final quiz = pageQuizzes[index];
              final id = quiz['id'] as int;
              return RepaintBoundary(
                child: BulkQuizListItem.build(
                  quiz: quiz,
                  fullText: vm.getFullQuizText(quiz),
                  status: vm.analysisStatus[id] ?? 0,
                  displayCount: _getDisplayCount(vm, quiz, id),
                  onTap: () => _showReviewDialog(context, vm, quiz),
                ),
              );
            },
          );
        },
      ),
    );
  }

  int _getDisplayCount(BulkSimilarManagementViewModel vm, Map<String, dynamic> quiz, int id) {
    final recs = vm.tempRecommendations[id] ?? [];
    final storedCount = (quiz['related_quiz_ids'] as List?)?.length ?? 0;
    return recs.length > storedCount ? recs.length : storedCount;
  }

  void _showReviewDialog(BuildContext context, BulkSimilarManagementViewModel vm, Map<String, dynamic> quiz) {
    showDialog(
      context: context,
      builder: (context) => SimilarQuizReviewDialog(
        quiz: quiz,
        selectedYear: vm.selectedYear,
        selectedRound: vm.selectedRound,
        initialRecommendations: vm.tempRecommendations[quiz['id']] ?? [],
        quizRepo: quizRepo,
        onUpdate: (updatedRecommendations) => vm.updateRecommendation(quiz['id'] as int, updatedRecommendations),
      ),
    );
  }
}
