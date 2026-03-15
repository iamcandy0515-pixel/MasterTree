import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/design_system.dart';
import '../../../viewmodels/quiz_viewmodel.dart';

class QuizHintToolbar extends StatelessWidget {
  const QuizHintToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Selector<QuizViewModel, int>(
          selector: (_, vm) => vm.viewedHintsCount,
          builder: (context, count, _) => _buildHintHeader(count),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Selector<QuizViewModel, String>(
                  selector: (_, vm) => vm.selectedHint,
                  builder: (context, selected, _) {
                    final vm = context.read<QuizViewModel>();
                    return Row(
                      children: [
                        _buildHintItem(vm, selected, Icons.energy_savings_leaf, '잎'),
                        _buildHintItem(vm, selected, Icons.texture, '수피'),
                        _buildHintItem(vm, selected, Icons.local_florist, '꽃'),
                        _buildHintItem(vm, selected, Icons.eco, '열매/겨울눈'),
                        _buildHintItem(vm, selected, Icons.category, '대표'),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHintHeader(int count) {
    return Row(
      children: [
        const Text(
          '힌트 보기',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lightbulb, size: 10, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                '$count',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHintItem(QuizViewModel vm, String selectedHint, IconData icon, String label) {
    bool isActive = selectedHint == label;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => vm.selectHint(label),
        child: Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                boxShadow: isActive ? [AppDesign.glowPrimary] : null,
              ),
              child: Icon(
                icon,
                color: isActive ? AppColors.backgroundDark : Colors.white54,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
