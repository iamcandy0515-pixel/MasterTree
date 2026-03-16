import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/quiz_extraction_step2_viewmodel.dart';

class PdfExtractionModule extends StatelessWidget {
  final VoidCallback onExtractQuiz;

  const PdfExtractionModule({super.key, required this.onExtractQuiz});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<QuizExtractionStep2ViewModel>(context);
    const primaryColor = Color(0xFF2BEE8C);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(
                  Icons.settings_input_component,
                  color: primaryColor,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  '추출 조건 설정',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: vm.isExtracting ? null : onExtractQuiz,
              icon: vm.isExtracting
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Icon(Icons.bolt, size: 16),
              label: const Text('퀴즈 추출 시작'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildInfoField('과목', vm.selectedSubject ?? '미선택'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoField(
                      '연도',
                      vm.selectedYear?.toString() ?? '미선택',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoField(
                      '회차',
                      vm.selectedRound?.toString() ?? '미선택',
                    ),
                  ),
                ],
              ),
              if (vm.extractionProgress > 0) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: vm.extractionProgress,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation(primaryColor),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(vm.extractionProgress * 100).toInt()}% 추출 중...',
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
