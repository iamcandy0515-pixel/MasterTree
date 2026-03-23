import 'package:flutter/material.dart';
import '../../../core/design_system.dart';
import '../widgets/stat_summary_card.dart';

class QuizStatsTab extends StatelessWidget {
  final Map<String, dynamic> stats;

  const QuizStatsTab({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          StatSummaryCard(
            title: '수목 식별 퀴즈 성과',
            data: stats['quiz'] ?? {},
            accentColor: AppColors.primary,
            icon: Icons.analytics,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
