import 'package:flutter/material.dart';
import '../../../viewmodels/bulk_extraction_viewmodel.dart';
import './bulk_image_editor_section.dart';

class BulkExtractionEditorForm extends StatelessWidget {
  final int selectedTabIndex;
  final TextEditingController questionController;
  final TextEditingController answerController;
  final TextEditingController hintController;
  final TextEditingController wrongAnswerController;
  final BulkExtractionViewModel vm;

  static const primaryColor = Color(0xFF2BEE8C);
  static const surfaceDark = Color(0xFF1A2E24);

  const BulkExtractionEditorForm({
    super.key,
    required this.selectedTabIndex,
    required this.questionController,
    required this.answerController,
    required this.hintController,
    required this.wrongAnswerController,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BulkImageEditorSection(
            label: '문제',
            controller: questionController,
            onChanged: (v) => vm.updateQuizContent(selectedTabIndex, 'question', v),
            lines: 5,
            field: 'question',
            selectedTabIndex: selectedTabIndex,
            vm: vm,
          ),
          BulkImageEditorSection(
            label: '정답 및 해설',
            controller: answerController,
            onChanged: (v) => vm.updateQuizContent(selectedTabIndex, 'explanation', v),
            lines: 5,
            field: 'explanation',
            selectedTabIndex: selectedTabIndex,
            vm: vm,
          ),
          BulkImageEditorSection(
            label: '힌트',
            controller: hintController,
            onChanged: (v) => vm.updateQuizContent(selectedTabIndex, 'hint', v),
            lines: 3,
            field: 'hint',
            selectedTabIndex: selectedTabIndex,
            vm: vm,
          ),
          BulkImageEditorSection(
            label: '오답 (대표)',
            controller: wrongAnswerController,
            onChanged: (v) => vm.updateQuizContent(selectedTabIndex, 'wrong_answer', v),
            lines: 2,
            field: 'wrong_answer',
            selectedTabIndex: selectedTabIndex,
            vm: vm,
          ),
        ],
      ),
    );
  }

  Widget _buildEditField(
    String label,
    TextEditingController controller,
    Function(String) onChanged,
    int lines,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: primaryColor,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: lines,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: surfaceDark,
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
