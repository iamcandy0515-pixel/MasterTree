import 'package:flutter/material.dart';
import 'parts/file_id_input.dart';
import 'parts/exam_category_dropdowns.dart';
import 'parts/extraction_range_inputs.dart';
import 'parts/extract_action_button.dart';

class BulkExtractionFilterPanel extends StatelessWidget {
  final TextEditingController fileIdController;
  final TextEditingController startController;
  final TextEditingController endController;
  final String? subject;
  final int? year;
  final int? round;
  final bool isLoading;
  final bool isFilterComplete;
  final Function(String) onFileIdChanged;
  final Function(String?) onSubjectChanged;
  final Function(String?) onYearChanged;
  final Function(String?) onRoundChanged;
  final Function(String) onStartChanged;
  final Function(String) onEndChanged;
  final VoidCallback onExtractPressed;

  static const primaryColor = Color(0xFF2BEE8C);
  static const surfaceDark = Color(0xFF1A2E24);

  const BulkExtractionFilterPanel({
    super.key,
    required this.fileIdController,
    required this.startController,
    required this.endController,
    required this.subject,
    required this.year,
    required this.round,
    required this.isLoading,
    required this.isFilterComplete,
    required this.onFileIdChanged,
    required this.onSubjectChanged,
    required this.onYearChanged,
    required this.onRoundChanged,
    required this.onStartChanged,
    required this.onEndChanged,
    required this.onExtractPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      color: surfaceDark.withOpacity(0.5),
      child: Column(
        children: [
          FileIdInput(
            controller: fileIdController,
            onChanged: onFileIdChanged,
            primaryColor: primaryColor,
            surfaceDark: surfaceDark,
          ),
          const SizedBox(height: 8),
          ExamCategoryDropdowns(
            subject: subject,
            year: year,
            round: round,
            onSubjectChanged: onSubjectChanged,
            onYearChanged: onYearChanged,
            onRoundChanged: onRoundChanged,
            primaryColor: primaryColor,
            surfaceDark: surfaceDark,
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 10,
            children: [
              ExtractionRangeInputs(
                startController: startController,
                endController: endController,
                onStartChanged: onStartChanged,
                onEndChanged: onEndChanged,
                surfaceDark: surfaceDark,
              ),
              ExtractActionButton(
                isLoading: isLoading,
                isFilterComplete: isFilterComplete,
                onExtractPressed: onExtractPressed,
                primaryColor: primaryColor,
                surfaceDark: surfaceDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
