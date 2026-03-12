import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../viewmodels/bulk_extraction_viewmodel.dart';
import '../../../widgets/image_manager_dialog.dart';

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
          _buildEditFieldWithImages(
            context,
            '문제',
            questionController,
            (v) => vm.updateQuizContent(selectedTabIndex, 'question', v),
            5,
            'question',
          ),
          _buildEditFieldWithImages(
            context,
            '정답 및 해설',
            answerController,
            (v) => vm.updateQuizContent(selectedTabIndex, 'explanation', v),
            5,
            'explanation',
          ),
          _buildEditField(
            '힌트',
            hintController,
            (v) => vm.updateQuizContent(selectedTabIndex, 'hint', v),
            3,
          ),
          _buildEditField(
            '오답 (대표)',
            wrongAnswerController,
            (v) => vm.updateQuizContent(selectedTabIndex, 'wrong_answer', v),
            2,
          ),
        ],
      ),
    );
  }

  Widget _buildEditFieldWithImages(
    BuildContext context,
    String label,
    TextEditingController controller,
    Function(String) onChanged,
    int lines,
    String field,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            TextButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => ImageManagerDialog(
                  viewModel: vm,
                  qNum: selectedTabIndex,
                  field: field,
                ),
              ),
              icon: Icon(
                vm.hasImage(selectedTabIndex, field)
                    ? Icons.image
                    : Icons.image_outlined,
                color: primaryColor,
                size: 18,
              ),
              label: Text(
                '이미지 관리${vm.hasImage(selectedTabIndex, field) ? ' (첨부됨)' : ''}',
                style: const TextStyle(color: primaryColor, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: lines,
          onChanged: onChanged,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black26,
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
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
          style: const TextStyle(color: Colors.white, fontSize: 14),
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
