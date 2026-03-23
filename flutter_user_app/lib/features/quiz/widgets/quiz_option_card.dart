import 'package:flutter/material.dart';
import '../../../../core/design_system.dart';

class QuizOptionCard extends StatelessWidget {
  final int index;
  final String text;
  final bool isSelected;
  final bool isAnswerSubmitted;
  final int correctIndex;
  final VoidCallback onTap;

  const QuizOptionCard({
    super.key,
    required this.index,
    required this.text,
    required this.isSelected,
    required this.isAnswerSubmitted,
    required this.correctIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool showCorrect = isAnswerSubmitted && index == correctIndex;
    bool showWrong = isAnswerSubmitted && isSelected && index != correctIndex;

    Color borderColor = Colors.white12;
    Color bgColor = AppColors.surfaceDark;

    if (isAnswerSubmitted) {
      if (showCorrect) {
        borderColor = Colors.green;
        bgColor = Colors.green.withOpacity(0.1);
      } else if (showWrong) {
        borderColor = Colors.red;
        bgColor = Colors.red.withOpacity(0.1);
      }
    } else if (isSelected) {
      borderColor = AppColors.primary;
      bgColor = AppColors.primary.withOpacity(0.1);
    }

    return GestureDetector(
      onTap: isAnswerSubmitted ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: isSelected || showCorrect ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.white24,
                ),
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: isSelected ? AppColors.backgroundDark : Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            if (showCorrect) const Icon(Icons.check_circle, color: Colors.green),
            if (showWrong) const Icon(Icons.cancel, color: Colors.red),
          ],
        ),
      ),
    );
  }
}
