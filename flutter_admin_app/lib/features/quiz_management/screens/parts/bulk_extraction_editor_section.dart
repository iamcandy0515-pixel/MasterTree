import 'package:flutter/material.dart';
import '../../viewmodels/bulk_extraction_viewmodel.dart';
import '../widgets/bulk_extraction/bulk_extraction_question_tabs.dart';
import '../widgets/bulk_extraction/bulk_extraction_editor_form.dart';

class BulkExtractionEditorSection extends StatelessWidget {
  final BulkExtractionViewModel vm;
  final int selectedTabIndex;
  final ScrollController scrollController;
  final TextEditingController questionController;
  final TextEditingController answerController;
  final TextEditingController hintController;
  final TextEditingController wrongAnswerController;
  final Function(int) onTabSelected;

  const BulkExtractionEditorSection({
    super.key,
    required this.vm,
    required this.selectedTabIndex,
    required this.scrollController,
    required this.questionController,
    required this.answerController,
    required this.hintController,
    required this.wrongAnswerController,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BulkExtractionQuestionTabs(
          startNumber: vm.startNumber,
          endNumber: vm.endNumber,
          selectedTabIndex: selectedTabIndex,
          scrollController: scrollController,
          extractedQuizzes: vm.extractedQuizzes,
          hasImage: vm.hasImage,
          onTabSelected: onTabSelected,
        ),
        const Divider(height: 1, color: Colors.white10),
        Expanded(
          child: BulkExtractionEditorForm(
            selectedTabIndex: selectedTabIndex,
            questionController: questionController,
            answerController: answerController,
            hintController: hintController,
            wrongAnswerController: wrongAnswerController,
            vm: vm,
          ),
        ),
      ],
    );
  }
}
