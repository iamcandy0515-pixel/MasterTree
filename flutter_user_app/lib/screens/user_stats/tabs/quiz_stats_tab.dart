import 'package:flutter/material.dart';
import '../../../core/design_system.dart';
import '../widgets/stat_summary_card.dart';

class QuizStatsTab extends StatelessWidget {
  final Map<String, dynamic> stats;
  final List<Map<String, dynamic>> categories;

  const QuizStatsTab({super.key, required this.stats, required this.categories});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatSummaryCard(
            title: '수목 식별 퀴즈 성과',
            data: Map<String, dynamic>.from(stats['quiz'] as Map? ?? <String, dynamic>{}),
            accentColor: AppColors.primary,
            icon: Icons.analytics,
          ),
          const SizedBox(height: 30),
          const Text(
            '분류별 학습 현황',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          if (categories.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text('학습 데이터가 없습니다.', style: TextStyle(color: AppColors.textMuted)),
              ),
            )
          else
            ...categories.map((cat) => _buildCategoryCard(cat)).toList(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> cat) {
    final double accuracy = (cat['accuracy_rate'] as num?)?.toDouble() ?? 0.0;
    
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
              Text(
                cat['category_name']?.toString() ?? '알 수 없음',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${accuracy.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: AppColors.primary,
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
              _buildMiniStat('전체', (cat['total_count'] ?? 0).toString()),
              _buildMiniStat('습득완료', (cat['mastered_count'] ?? 0).toString(), color: AppColors.primary),
              _buildMiniStat('도전중', (cat['in_progress_count'] ?? 0).toString(), color: Colors.orange),
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
