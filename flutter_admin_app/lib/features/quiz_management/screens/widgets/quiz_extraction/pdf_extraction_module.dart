import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/quiz_extraction_step2_viewmodel.dart';

class PdfExtractionModule extends StatelessWidget {
  final VoidCallback onValidateFile;
  final VoidCallback onExtractQuiz;

  const PdfExtractionModule({
    super.key,
    required this.onValidateFile,
    required this.onExtractQuiz,
  });

  static const primaryColor = Color(0xFF2BEE8C);
  static const backgroundDark = Color(0xFF102219);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<QuizExtractionStep2ViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.settings_input_component,
                  color: primaryColor,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  '추출조건',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: vm.isValidating ? null : onValidateFile,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orangeAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: vm.isValidating
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.orangeAccent,
                          ),
                        )
                      : const Text(
                          '파일검증',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onExtractQuiz,
                  style: TextButton.styleFrom(
                    foregroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'PDF 추출',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              '문제번호 :',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: vm.selectedQuestion,
                  isExpanded: false,
                  dropdownColor: backgroundDark,
                  icon: const Icon(
                    Icons.expand_more,
                    color: primaryColor,
                    size: 16,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  onChanged: (int? newValue) {
                    if (newValue != null) vm.setSelectedQuestion(newValue);
                  },
                  items:
                      List.generate(
                            vm.selectedQuestion > 20 ? vm.selectedQuestion : 20,
                            (index) => index + 1,
                          )
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(
                                'Q$value',
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
