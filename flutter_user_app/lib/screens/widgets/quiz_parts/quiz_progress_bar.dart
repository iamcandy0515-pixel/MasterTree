import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/design_system.dart';
import '../../../viewmodels/quiz_viewmodel.dart';

/// Isolated Quiz Progress Bar (Strategy: Partial Rebuild via Selector)
/// Only rebuilds when progress-related values change.
class QuizProgressBar extends StatelessWidget {
  const QuizProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Selector<QuizViewModel, double>(
          selector: (_, vm) => vm.totalQuestions > 0 
              ? vm.solvedCount / vm.totalQuestions 
              : 0.0,
          builder: (context, progress, _) {
            return LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 4,
            );
          },
        ),
      ),
    );
  }
}
