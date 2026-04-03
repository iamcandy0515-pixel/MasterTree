import 'package:flutter/material.dart';
import '../../../viewmodels/quiz_extraction_step2_viewmodel.dart';

class PdfExtractionModule extends StatelessWidget {
  final VoidCallback onValidateFile;
  final VoidCallback onExtractQuiz;

  const PdfExtractionModule({
    super.key,
    required this.onValidateFile,
    required this.onExtractQuiz,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<QuizExtractionStep2ViewModel>();
    const primaryColor = Color(0xFF2BEE8C);
    const backgroundDark = Color(0xFF102219);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.picture_as_pdf, color: primaryColor, size: 20),
              const SizedBox(width: 10),
              const Text(
                'PDF 퀴즈 추출',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _buildQuestionSelector(vm, backgroundDark, primaryColor),
            ],
          ),
          const SizedBox(height: 20),
          _buildActionButtons(vm, primaryColor),
        ],
      ),
    );
  }

  Widget _buildQuestionSelector(
    QuizExtractionStep2ViewModel vm,
    Color backgroundDark,
    Color primaryColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          '추출할 문항 번호',
          style: TextStyle(color: Colors.grey, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _safeInt(vm.selectedQuestion),
              isExpanded: false,
              dropdownColor: backgroundDark,
              icon: const Icon(Icons.expand_more, color: primaryColor, size: 16),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              onChanged: (int? newValue) {
                if (newValue != null) vm.setSelectedQuestion(newValue);
              },
              items: List.generate(
                _safeInt(vm.selectedQuestion) > 20 ? _safeInt(vm.selectedQuestion) : 20,
                (index) => index + 1,
              )
              .map(
                (value) => DropdownMenuItem<int>(
                  value: value,
                  child: Text(
                    'Q$value',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              )
              .toList(),
            ),
          ),
        ),
      ],
    );
  }

  int _safeInt(dynamic val) {
    if (val == null) return 1;
    if (val is int) return val;
    return int.tryParse(val.toString()) ?? 1;
  }

  Widget _buildActionButtons(QuizExtractionStep2ViewModel vm, Color primaryColor) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: vm.isStep1Validating ? null : onValidateFile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.05),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.white10),
              ),
            ),
            icon: vm.isStep1Validating
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('파일 검증', style: TextStyle(fontSize: 13)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: (vm.isStep1Validating || vm.isStep2Extracting || !vm.isStep1Done)
                ? null
                : onExtractQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            icon: vm.isStep2Extracting
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                : const Icon(Icons.auto_awesome, size: 18),
            label: const Text('AI 퀴즈 추출', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ),
      ],
    );
  }
}
