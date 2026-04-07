import 'package:flutter/material.dart';
import '../widgets/stat_summary_card.dart';

class PastExamStatsTab extends StatelessWidget {
  final Map<String, dynamic> stats;

  const PastExamStatsTab({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          StatSummaryCard(
            title: '기출 문제 학습 성과',
            data: Map<String, dynamic>.from(stats['pastExam'] as Map? ?? <String, dynamic>{}),
            accentColor: Colors.orangeAccent,
            icon: Icons.analytics,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
