import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/design_system.dart';
import '../../../viewmodels/quiz_viewmodel.dart';

class QuizOptionsList extends StatelessWidget {
  const QuizOptionsList({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<QuizViewModel>();
    final question = vm.currentQuestion;

    return Column(
      children: List.generate(question.options.length, (index) {
        final label = question.options[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _buildOptionItem(vm, index, label),
        );
      }),
    );
  }

  Widget _buildOptionItem(QuizViewModel vm, int index, String label) {
    final isSelected = vm.selectedAnswer == index;
    final isCorrect = vm.currentQuestion.correctAnswerIndex == index;
    final showCorrect = isSelected && isCorrect;
    final showWrong = isSelected && !vm.isCorrect;

    return GestureDetector(
      onTap: vm.selectedAnswer == null ? () => vm.selectAnswer(index) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: showCorrect
              ? AppColors.primary.withOpacity(0.12)
              : showWrong
              ? Colors.red.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: showCorrect
                ? AppColors.primary.withOpacity(0.3)
                : showWrong
                ? Colors.red.withOpacity(0.3)
                : Colors.white.withOpacity(0.03),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: showCorrect
                      ? AppColors.primary
                      : showWrong
                      ? Colors.redAccent
                      : Colors.white.withOpacity(0.6),
                  fontSize: 13,
                  fontWeight: showCorrect || showWrong ? FontWeight.bold : FontWeight.w400,
                ),
              ),
            ),
            if (showCorrect)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 18)
            else if (showWrong)
              Icon(Icons.cancel, color: Colors.red.withOpacity(0.8), size: 18),
          ],
        ),
      ),
    );
  }
}
