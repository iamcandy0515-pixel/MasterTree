import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/design_system.dart';
import 'package:flutter_user_app/controllers/past_exam_detail_controller.dart';
import 'package:flutter_user_app/core/api_service.dart';

// Modular Widgets
import 'past_exam/widgets/exam_info_banner.dart';
import 'past_exam/widgets/quiz_content_card.dart';
import 'past_exam/widgets/option_selector_list.dart';
import 'past_exam/widgets/explanation_panel.dart';
import 'past_exam/widgets/related_quiz_section.dart';

// New Parts
import 'past_exam/parts/past_exam_app_bar.dart';

/// Refactored Past Exam Detail Screen (Strategy: Sliver Optimization)
/// Optimized for mobile load balancing by switching to CustomScrollView.
/// Adheres to DEVELOPMENT_RULES.md (<200 lines).
class PastExamDetailScreen extends StatefulWidget {
  final int quizId;

  const PastExamDetailScreen({super.key, required this.quizId});

  @override
  State<PastExamDetailScreen> createState() => _PastExamDetailScreenState();
}

class _PastExamDetailScreenState extends State<PastExamDetailScreen> {
  final PastExamDetailController _controller = PastExamDetailController();

  // Local State for UI Expansion (Avoids full screen rebuilds when possible)
  final ValueNotifier<bool> _isQuestionExpanded = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isExplanationExpanded = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _controller.fetchQuizData(
      quizId: widget.quizId,
      onUpdate: () => setState(() {}),
      onError: (message) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('데이터 로딩 실패: $message')),
          );
          Navigator.pop(context);
        }
      },
    );
  }

  @override
  void dispose() {
    ApiService.syncPendingAttempts();
    _isQuestionExpanded.dispose();
    _isExplanationExpanded.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await ApiService.syncPendingAttempts();
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: const PastExamAppBar(),
        body: _controller.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _buildSliverBody(),
      ),
    );
  }

  Widget _buildSliverBody() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // 1. Info Banner
              ExamInfoBanner(
                subject: _controller.subject,
                year: _controller.year,
                round: _controller.round,
                questionNo: _controller.questionNo,
              ),
              const SizedBox(height: 20),

              // 2. Question Area (Stateless Expansion)
              ValueListenableBuilder<bool>(
                valueListenable: _isQuestionExpanded,
                builder: (context, expanded, _) {
                  return QuizContentCard(
                    contentBlocks: _controller.contentBlocks,
                    isExpanded: expanded,
                    onToggleExpand: () => _isQuestionExpanded.value = !expanded,
                  );
                },
              ),
              const SizedBox(height: 20),

              // 3. Option Selection
              OptionSelectorList(
                options: _controller.options,
                selectedIndex: _controller.selectedOptionIndex,
                correctIndex: _controller.correctOptionIndex,
                isAnswered: _controller.isAnswered,
                onSelect: (index) => _controller.selectOption(
                  index, 
                  onUpdate: () => setState(() {}),
                ),
              ),
              const SizedBox(height: 20),

              // 4. Explanation & Hints (Conditional Rendering)
              if (_controller.isAnswered)
                ValueListenableBuilder<bool>(
                  valueListenable: _isExplanationExpanded,
                  builder: (context, expanded, _) {
                    return ExplanationPanel(
                      explanationBlocks: _controller.explanationBlocks,
                      hintText: _controller.hintText,
                      isExpanded: expanded,
                      onToggleExpand: () => _isExplanationExpanded.value = !expanded,
                    );
                  },
                ),

              // 5. Similar Quizzes
              RelatedQuizSection(similarQuizzes: _controller.similarQuizzes),
              
              const SizedBox(height: 48),
            ]),
          ),
        ),
      ],
    );
  }
}
