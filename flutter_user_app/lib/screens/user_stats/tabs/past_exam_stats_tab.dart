import 'package:flutter/material.dart';
import '../widgets/stat_summary_card.dart';

import '../../../core/design_system.dart';

class PastExamStatsTab extends StatelessWidget {
  final Map<String, dynamic> stats;
  final List<Map<String, dynamic>> exams;

  const PastExamStatsTab({super.key, required this.stats, required this.exams});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatSummaryCard(
            title: '기출 문제 학습 성과',
            data: Map<String, dynamic>.from(stats['pastExam'] as Map? ?? <String, dynamic>{}),
            accentColor: Colors.orangeAccent,
            icon: Icons.analytics,
          ),
          const SizedBox(height: 30),
          const Text(
            '회차별 학습 현황',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          if (exams.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text('학습 데이터가 없습니다.', style: TextStyle(color: AppColors.textMuted)),
              ),
            )
          else
            ...exams.map((exam) => _buildExamCard(exam)).toList(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildExamCard(Map<String, dynamic> exam) {
    final double accuracy = (exam['accuracy_rate'] as num?)?.toDouble() ?? 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  exam['subject_name']?.toString() ?? '기출문제',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${accuracy.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('전체', (exam['total_count'] ?? 0).toString()),
              _buildMiniStat('습득완료', (exam['mastered_count'] ?? 0).toString(), color: Colors.orangeAccent),
              _buildMiniStat('도전중', (exam['in_progress_count'] ?? 0).toString(), color: Colors.white70),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
