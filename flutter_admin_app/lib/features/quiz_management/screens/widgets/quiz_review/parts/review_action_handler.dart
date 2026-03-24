import 'package:flutter/material.dart';
import '../../../../viewmodels/quiz_review_detail_viewmodel.dart';
import '../../../../repositories/quiz_repository.dart';
import '../../../../../../core/utils/snackbar_util.dart';
import '../../similar_quiz_review_dialog.dart';
import '../../../quiz_review_detail_screen.dart'; // Circular ref but valid for mixin

/// Quiz Review Action Handler (Strategy: Processing Logic Split)
/// UI에서 복잡한 비즈니스 액션(저장, AI 검수, 추천) 및 스낵바 제어를 분리함.
mixin QuizReviewActionHandler on State<QuizReviewDetailScreen> {
  /// 데이터 저장 핸들러
  Future<void> handleSave(QuizReviewDetailViewModel vm) async {
    try {
      await vm.saveQuiz(widget.quizId);
      if (!mounted) return;
      SnackBarUtil.showFloating(context, '성공적으로 저장되었습니다.');
    } catch (e) {
      if (!mounted) return;
      SnackBarUtil.showFloating(context, '저장 실패: $e', isError: true);
    }
  }

  /// 이미지 업로드 핸들러
  Future<void> handleImageUpload(QuizReviewDetailViewModel vm, dynamic img, String field) async {
    try {
      final bytes = await img.readAsBytes();
      await vm.uploadImage(bytes, img.name, field);
      if (!mounted) return;
      SnackBarUtil.showFloating(context, '이미지 업로드 완료');
    } catch (e) {
      if (!mounted) return;
      SnackBarUtil.showFloating(context, '업로드 실패: $e', isError: true);
    }
  }

  /// AI 내용 검수 핸들러
  Future<void> handleAiReview(QuizReviewDetailViewModel vm) async {
    try {
      final res = await vm.aiReview();
      if (!mounted) return;
      _showReviewResultDialog(context, res);
    } catch (e) {
      if (!mounted) return;
      SnackBarUtil.showFloating(context, 'AI 검수 실패: $e', isError: true);
    }
  }

  /// AI 오답 생성 핸들러
  Future<void> handleAiGenerate(QuizReviewDetailViewModel vm) async {
    try {
      await vm.generateDistractors();
      if (!mounted) return;
      SnackBarUtil.showFloating(context, 'AI 오답 생성 완료');
    } catch (e) {
      if (!mounted) return;
      SnackBarUtil.showFloating(context, '오답 생성 실패: $e', isError: true);
    }
  }

  /// AI 유사문제 추천 핸들러
  Future<void> handleAiRecommend(QuizReviewDetailViewModel vm) async {
    try {
      final related = await vm.recommendSimilar(widget.quizId);
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => SimilarQuizReviewDialog(
          quiz: {
            'id': widget.quizId,
            'question_number': vm.questionNo,
            'content_blocks': vm.contentBlocks,
            'related_quiz_ids': vm.selectedRelatedIds,
          },
          selectedYear: vm.year,
          selectedRound: vm.round,
          initialRecommendations: related.map((e) => e as Map<String, dynamic>).toList(),
          quizRepo: QuizRepository(),
          onUpdate: (updatedList) {
            vm.selectedRelatedIds = updatedList.map((e) => e['id'] as int).toList();
            vm.loadRelatedQuizzesMetadata();
          },
        ),
      );
    } catch (e) {
      if (!mounted) return;
      SnackBarUtil.showFloating(context, '추천 실패: $e', isError: true);
    }
  }

  /// AI 검수 결과 다이얼로그 표시
  void _showReviewResultDialog(BuildContext context, Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2E24),
        title: const Text('AI 검수 결과', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReviewRow('일관성', result['is_consistent'] == true ? '✅ 일치' : '❌ 불일치'),
              const SizedBox(height: 12),
              const Text('분석 내용:', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
              Text(result['reason'] ?? '내용 없음', style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인', style: TextStyle(color: Color(0xFF2BEE8C))),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Row(
      children: [
        Text('$label: ', style: const TextStyle(color: Colors.white70)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
