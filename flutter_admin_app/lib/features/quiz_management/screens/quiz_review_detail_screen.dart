import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/quiz_review_detail_viewmodel.dart';
import '../repositories/quiz_repository.dart';
import '../../../core/utils/snackbar_util.dart';
import './widgets/quiz_review/quiz_detail_header.dart';
import './widgets/quiz_review/quiz_content_card.dart';
import './widgets/quiz_review/quiz_explanation_card.dart';
import './widgets/quiz_review/quiz_options_card.dart';
import './widgets/quiz_review/quiz_hint_card.dart';
import './widgets/quiz_review/quiz_related_card.dart';
import './widgets/similar_quiz_review_dialog.dart';

class QuizReviewDetailScreen extends StatefulWidget {
  final int quizId;

  const QuizReviewDetailScreen({super.key, required this.quizId});

  @override
  State<QuizReviewDetailScreen> createState() => _QuizReviewDetailScreenState();
}

class _QuizReviewDetailScreenState extends State<QuizReviewDetailScreen> {
  late final QuizReviewDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = QuizReviewDetailViewModel();
    _viewModel.loadQuiz(widget.quizId);
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2BEE8C);
    const backgroundDark = Color(0xFF102219);

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: backgroundDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('문제 검수 및 상세 편집', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
          actions: [
            Consumer<QuizReviewDetailViewModel>(
              builder: (context, vm, _) => vm.isSaving
                  ? const Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: primaryColor, strokeWidth: 2)))
                  : TextButton.icon(
                      onPressed: () => _handleSave(context, vm),
                      icon: const Icon(Icons.save, color: primaryColor, size: 20),
                      label: const Text('저장', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                    ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Consumer<QuizReviewDetailViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) return const Center(child: CircularProgressIndicator(color: primaryColor));

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  QuizDetailHeader(subject: vm.subject, year: vm.year, round: vm.round, questionNo: vm.questionNo),
                  const SizedBox(height: 24),
                  QuizContentCard(
                    initialText: vm.questionText,
                    blocks: vm.contentBlocks,
                    isExpanded: vm.isContentExpanded,
                    onTextChanged: (val) => vm.questionText = val,
                    onToggleExpand: () => vm.toggleExpanded('content'),
                    onUploadImage: (img) async => await _handleImageUpload(context, vm, img, 'content'),
                    onRemoveImage: (idx) => vm.removeImage(idx, 'content'),
                  ),
                  const SizedBox(height: 24),
                  QuizExplanationCard(
                    initialText: vm.explanationText,
                    blocks: vm.explanationBlocks,
                    isExpanded: vm.isExpExpanded,
                    isReviewing: vm.isReviewing,
                    onTextChanged: (val) => vm.explanationText = val,
                    onToggleExpand: () => vm.toggleExpanded('exp'),
                    onUploadImage: (img) async => await _handleImageUpload(context, vm, img, 'exp'),
                    onRemoveImage: (idx) => vm.removeImage(idx, 'exp'),
                    onAiReview: () => _handleAiReview(context, vm),
                  ),
                  const SizedBox(height: 24),
                  QuizOptionsCard(
                    correctOption: vm.correctOption,
                    incorrectOptions: vm.incorrectOptions,
                    isGenerating: vm.isGenerating,
                    onCorrectOptionChanged: (val) => vm.correctOption = val,
                    onIncorrectOptionChanged: (idx, val) => vm.incorrectOptions[idx] = val,
                    onAiGenerate: () => _handleAiGenerate(context, vm),
                  ),
                  const SizedBox(height: 24),
                  QuizHintCard(initialText: vm.hintText, onTextChanged: (val) => vm.hintText = val),
                  const SizedBox(height: 24),
                  QuizRelatedCard(
                    relatedQuizzes: vm.relatedQuizzesMetadata,
                    currentPage: vm.currentRelatedPage,
                    isRecommending: vm.isRecommending,
                    onPageChanged: (p) => vm.setRelatedPage(p),
                    onRemoveRelated: (id) => vm.removeRelated(id),
                    onAiRecommend: () => _handleAiRecommend(context, vm),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleSave(BuildContext context, QuizReviewDetailViewModel vm) async {
    try {
      await vm.saveQuiz(widget.quizId);
      if (mounted) SnackBarUtil.showFloating(context, '성공적으로 저장되었습니다.');
    } catch (e) {
      if (mounted) SnackBarUtil.showFloating(context, '저장 실패: $e', isError: true);
    }
  }

  Future<void> _handleImageUpload(BuildContext context, QuizReviewDetailViewModel vm, dynamic img, String field) async {
    try {
      final bytes = await img.readAsBytes();
      await vm.uploadImage(bytes, img.name, field);
      if (mounted) SnackBarUtil.showFloating(context, '이미지 업로드 완료');
    } catch (e) {
      if (mounted) SnackBarUtil.showFloating(context, '업로드 실패: $e', isError: true);
    }
  }

  Future<void> _handleAiReview(BuildContext context, QuizReviewDetailViewModel vm) async {
    try {
      final res = await vm.aiReview();
      if (mounted) _showReviewResultDialog(context, res);
    } catch (e) {
      if (mounted) SnackBarUtil.showFloating(context, 'AI 검수 실패: $e', isError: true);
    }
  }

  Future<void> _handleAiGenerate(BuildContext context, QuizReviewDetailViewModel vm) async {
    try {
      await vm.generateDistractors();
      if (mounted) SnackBarUtil.showFloating(context, 'AI 오답 생성 완료');
    } catch (e) {
      if (mounted) SnackBarUtil.showFloating(context, '오답 생성 실패: $e', isError: true);
    }
  }

  Future<void> _handleAiRecommend(BuildContext context, QuizReviewDetailViewModel vm) async {
    try {
      final related = await vm.recommendSimilar(widget.quizId);
      if (mounted) {
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
      }
    } catch (e) {
      if (mounted) SnackBarUtil.showFloating(context, '추천 실패: $e', isError: true);
    }
  }

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
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('확인', style: TextStyle(color: Color(0xFF2BEE8C))))],
      ),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Row(children: [Text('$label: ', style: const TextStyle(color: Colors.white70)), Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]);
  }
}
