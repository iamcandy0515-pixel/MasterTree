import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/quiz_extraction_step2_viewmodel.dart';
import './extraction_search_input.dart';
import './extraction_filter_row.dart';
import './extraction_action_control.dart';

class UnifiedExtractionHeader extends StatefulWidget {
  const UnifiedExtractionHeader({super.key});

  @override
  State<UnifiedExtractionHeader> createState() => _UnifiedExtractionHeaderState();
}

class _UnifiedExtractionHeaderState extends State<UnifiedExtractionHeader> {
  final TextEditingController _fileSearchController = TextEditingController();
  static const surfaceDark = Color(0xFF1A2E24);

  @override
  void dispose() {
    _fileSearchController.dispose();
    super.dispose();
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color(0xFF2BEE8C).withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.only(bottom: 20, left: 50, right: 50),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<QuizExtractionStep2ViewModel>(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1단계: 파일 검색
          ExtractionSearchInput(
            controller: _fileSearchController,
            onSearch: (val) => vm.searchFiles(val),
          ),
          const SizedBox(height: 12),
          // 2단계: 필터 행
          ExtractionFilterRow(
            selectedSubject: vm.selectedSubject,
            selectedYear: vm.selectedYear?.toString(),
            selectedRound: vm.selectedRound?.toString(),
            onSubjectChanged: (val) => vm.updateFilters(subject: val),
            onYearChanged: (val) => vm.updateFilters(year: val),
            onRoundChanged: (val) => vm.updateFilters(round: val),
          ),
          const SizedBox(height: 12),
          // 3단계: 액션 컨트롤
          ExtractionActionControl(
            selectedQuestionNumber: vm.selectedQuestionNumber,
            isLoading: vm.isLoading,
            onQuestionNumberChanged: (qNum) => vm.updateFilters(questionNumber: qNum),
            onExtract: () async {
              final fileId = _fileSearchController.text.trim();
              if (fileId.isEmpty) {
                _showSnackBar(context, '파일 정보를 입력해주세요.');
                return;
              }
              await vm.startBatchExtractionAction(
                fileId: fileId,
                singleQuestionNumber: vm.selectedQuestionNumber,
                onProgress: (_, __) {},
                onMessage: (_) {},
              );
            },
          ),
        ],
      ),
    );
  }
}
