import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/design_system.dart';

class StatsSummaryCard extends StatelessWidget {
  final int overallAccuracy;
  final int totalAttempts;

  const StatsSummaryCard({
    super.key,
    required this.overallAccuracy,
    required this.totalAttempts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn('전체 정답률', '$overallAccuracy%', isPrimary: true),
          Container(height: 50, width: 1, color: Colors.white24),
          _buildStatColumn('풀이 문제 수', '$totalAttempts'),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, {bool isPrimary = false}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: isPrimary ? AppColors.primary : Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
