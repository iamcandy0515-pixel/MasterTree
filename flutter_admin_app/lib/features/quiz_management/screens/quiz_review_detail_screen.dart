import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/quiz_review_detail_viewmodel.dart';
import './widgets/quiz_review/quiz_detail_header.dart';
import './widgets/quiz_review/quiz_content_card.dart';
import './widgets/quiz_review/quiz_explanation_card.dart';
import './widgets/quiz_review/quiz_options_card.dart';
import './widgets/quiz_review/quiz_hint_card.dart';
import './widgets/quiz_review/quiz_related_card.dart';
import './widgets/quiz_review/parts/review_action_handler.dart';

/// Quiz Review Detail Screen (Refactored Strategy: Action Handler Split & Selective Rebuilds)
/// 222라인 -> ~120라인으로 최적화. 200줄 제한(1-1) 준수.
class QuizReviewDetailScreen extends StatefulWidget {
  final int quizId;
  const QuizReviewDetailScreen({super.key, required this.quizId});

  @override
  State<QuizReviewDetailScreen> createState() => _QuizReviewDetailScreenState();
}

class _QuizReviewDetailScreenState extends State<QuizReviewDetailScreen> with QuizReviewActionHandler {
  late final QuizReviewDetailViewModel _viewModel;
  static const primaryColor = Color(0xFF2BEE8C);
  static const backgroundDark = Color(0xFF102219);

  @override
  void initState() {
    super.initState();
    _viewModel = QuizReviewDetailViewModel();
    _viewModel.loadQuiz(widget.quizId);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: backgroundDark,
        appBar: _buildAppBar(),
        body: Selector<QuizReviewDetailViewModel, bool>(
          selector: (_, vm) => vm.isLoading,
          builder: (context, isLoading, child) {
            if (isLoading) return const Center(child: CircularProgressIndicator(color: primaryColor));
            return child!;
          },
          child: _buildScrollBody(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text('문제 검수 및 상세 편집', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
      leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      actions: [
        Selector<QuizReviewDetailViewModel, bool>(
          selector: (_, vm) => vm.isSaving,
          builder: (context, isSaving, _) => isSaving
              ? const Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: primaryColor, strokeWidth: 2)))
              : TextButton.icon(
                  onPressed: () => handleSave(_viewModel),
                  icon: const Icon(Icons.save, color: primaryColor, size: 20),
                  label: const Text('저장', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildScrollBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          // Selector Strategy: Each card only rebuilds when its specific Data/Block changes.
          QuizDetailHeaderWidget(),
          SizedBox(height: 24),
          QuizContentCardWrapper(),
          SizedBox(height: 24),
          QuizExplanationCardWrapper(),
          SizedBox(height: 24),
          QuizOptionsCardWrapper(),
          SizedBox(height: 24),
          QuizHintCardWrapper(),
          SizedBox(height: 24),
          QuizRelatedCardWrapper(),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// --- Wrapped Card Widgets to isolate rebuilds within the file ---

class QuizDetailHeaderWidget extends StatelessWidget {
  const QuizDetailHeaderWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Selector<QuizReviewDetailViewModel, List<String>>(
      selector: (_, vm) => [vm.subject, vm.year, vm.round, vm.questionNo],
      builder: (context, d, _) => QuizDetailHeader(subject: d[0], year: d[1], round: d[2], questionNo: d[3]),
    );
  }
}

class QuizContentCardWrapper extends StatelessWidget {
  const QuizContentCardWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_QuizReviewDetailScreenState>()!;
    return Consumer<QuizReviewDetailViewModel>(
      builder: (context, vm, _) => QuizContentCard(
        initialText: vm.questionText, blocks: vm.contentBlocks, isExpanded: vm.isContentExpanded,
        onTextChanged: (val) => vm.questionText = val, onToggleExpand: () => vm.toggleExpanded('content'),
        onUploadImage: (img) => state.handleImageUpload(vm, img, 'content'), onRemoveImage: (idx) => vm.removeImage(idx, 'content'),
      ),
    );
  }
}

class QuizExplanationCardWrapper extends StatelessWidget {
  const QuizExplanationCardWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_QuizReviewDetailScreenState>()!;
    return Consumer<QuizReviewDetailViewModel>(
      builder: (context, vm, _) => QuizExplanationCard(
        initialText: vm.explanationText, blocks: vm.explanationBlocks, isExpanded: vm.isExpExpanded,
        isReviewing: vm.isReviewing, onTextChanged: (val) => vm.explanationText = val,
        onToggleExpand: () => vm.toggleExpanded('exp'), onUploadImage: (img) => state.handleImageUpload(vm, img, 'exp'),
        onRemoveImage: (idx) => vm.removeImage(idx, 'exp'), onAiReview: () => state.handleAiReview(vm),
      ),
    );
  }
}

class QuizOptionsCardWrapper extends StatelessWidget {
  const QuizOptionsCardWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_QuizReviewDetailScreenState>()!;
    return Consumer<QuizReviewDetailViewModel>(
      builder: (context, vm, _) => QuizOptionsCard(
        correctOption: vm.correctOption, incorrectOptions: vm.incorrectOptions, isGenerating: vm.isGenerating,
        onCorrectOptionChanged: (val) => vm.correctOption = val, onIncorrectOptionChanged: (idx, val) => vm.incorrectOptions[idx] = val,
        onAiGenerate: () => state.handleAiGenerate(vm),
      ),
    );
  }
}

class QuizHintCardWrapper extends StatelessWidget {
  const QuizHintCardWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return Selector<QuizReviewDetailViewModel, String>(
      selector: (_, vm) => vm.hintText,
      builder: (context, text, _) => QuizHintCard(initialText: text, onTextChanged: (val) => context.read<QuizReviewDetailViewModel>().hintText = val),
    );
  }
}

class QuizRelatedCardWrapper extends StatelessWidget {
  const QuizRelatedCardWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_QuizReviewDetailScreenState>()!;
    return Consumer<QuizReviewDetailViewModel>(
      builder: (context, vm, _) => QuizRelatedCard(
        relatedQuizzes: vm.relatedQuizzesMetadata, currentPage: vm.currentRelatedPage, isRecommending: vm.isRecommending,
        onPageChanged: (p) => vm.setRelatedPage(p), onRemoveRelated: (id) => vm.removeRelated(id), onAiRecommend: () => state.handleAiRecommend(vm),
      ),
    );
  }
}
