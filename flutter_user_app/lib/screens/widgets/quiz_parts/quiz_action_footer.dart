import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/design_system.dart';
import '../../../viewmodels/quiz_viewmodel.dart';
import '../../quiz_result_screen.dart';

class QuizActionFooter extends StatelessWidget {
  const QuizActionFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<QuizViewModel>();
    
    // 선택된 답변이 없으면 표시하지 않음 (공간을 차지하지 않도록 Row 내부에서 처리)
    if (vm.selectedAnswer == null) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (!vm.isCorrect) ...[
          TextButton.icon(
            onPressed: () => vm.retry(),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('다시 풀기'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              backgroundColor: Colors.redAccent.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
        if (vm.isCorrect) ...[
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              if (vm.hasNext) {
                vm.nextQuestion();
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => QuizResultScreen(
                      correctCount: vm.correctCount,
                      accumulatedHintCount: vm.accumulatedHintCount,
                      solvedCount: vm.solvedCount,
                    ),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  vm.hasNext ? '다음문제' : '결과보기',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios, size: 12),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

