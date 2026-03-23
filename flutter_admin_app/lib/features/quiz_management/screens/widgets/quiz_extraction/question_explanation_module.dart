import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/quiz_extraction_step2_viewmodel.dart';
import 'package:flutter_admin_app/core/utils/snackbar_util.dart';
import 'parts/question_input_section.dart';
import 'parts/explanation_input_section.dart';
import 'parts/ai_review_result_dialog.dart';

class QuestionAndExplanationModule extends StatefulWidget {
  final TextEditingController questionController;
  final TextEditingController explanationController;

  const QuestionAndExplanationModule({
    super.key,
    required this.questionController,
    required this.explanationController,
  });

  @override
  State<QuestionAndExplanationModule> createState() =>
      _QuestionAndExplanationModuleState();
}

class _QuestionAndExplanationModuleState
    extends State<QuestionAndExplanationModule> {
  static const primaryColor = Color(0xFF2BEE8C);
  static const cardDark = Color(0xFF1A2E26);

  Future<void> _reviewExplanationAction() async {
    final vm = context.read<QuizExtractionStep2ViewModel>();
    final explanationText = widget.explanationController.text;

    try {
      final reviewData = await vm.reviewExplanationAction(explanationText);
      final isAligned = reviewData['isAligned'] ?? false;
      final score = reviewData['confidenceScore'] ?? 0;
      final suggestions = reviewData['suggestedFixes'] ?? [];
      final reviewNotes = reviewData['reviewNotes'] ?? '';

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AIReviewResultDialog(
            isAligned: isAligned,
            score: score,
            reviewNotes: reviewNotes,
            suggestions: suggestions,
            primaryColor: primaryColor,
            cardDark: cardDark,
            onApplyFirstSuggestion: () {
              if (suggestions.isNotEmpty) {
                widget.explanationController.text = suggestions.first;
              }
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtil.showFloating(context, e.toString(), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<QuizExtractionStep2ViewModel>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuestionInputSection(
          controller: widget.questionController,
          aiDetermination: vm.extractedFilterRawString,
          primaryColor: primaryColor,
        ),
        const SizedBox(height: 12),
        ExplanationInputSection(
          controller: widget.explanationController,
          isReviewing: vm.isReviewing,
          canReview: vm.extractedBlock != null,
          onReview: _reviewExplanationAction,
          primaryColor: primaryColor,
        ),
      ],
    );
  }
}
