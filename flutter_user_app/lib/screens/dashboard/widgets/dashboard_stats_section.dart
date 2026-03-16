import 'package:flutter/material.dart';
import '../../../core/design_system.dart';

class DashboardStatsSection extends StatelessWidget {
  final int treeCount;
  final int quizCount;
  final int similarCount;

  const DashboardStatsSection({
    super.key,
    required this.treeCount,
    required this.quizCount,
    required this.similarCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatItem('수목', treeCount, '종'),
            _buildDivider(),
            _buildStatItem('기출', quizCount, '문'),
            _buildDivider(),
            _buildStatItem('유사', similarCount, '조합'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, String unit) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        const SizedBox(width: 8),
        Text(
          count.toString(),
          style: const TextStyle(
            color: AppColors.textLight,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          unit,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 14,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white.withOpacity(0.1),
    );
  }
}

