import 'package:flutter/material.dart';
import '../../../core/design_system.dart';
import '../widgets/stat_summary_card.dart';

class OverallStatsTab extends StatelessWidget {
  final Map<String, dynamic> stats;

  const OverallStatsTab({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WelcomeSection(user: stats['user']),
          const SizedBox(height: 24),
          StatSummaryCard(
            title: '수목 퀴즈 학습 요약',
            data: stats['quiz'] ?? {},
            accentColor: AppColors.primary,
            icon: Icons.school,
          ),
          const SizedBox(height: 16),
          StatSummaryCard(
            title: '기출 문제 학습 요약',
            data: stats['pastExam'] ?? {},
            accentColor: Colors.orangeAccent,
            icon: Icons.history_edu,
          ),
        ],
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  final Map<String, dynamic>? user;

  const _WelcomeSection({this.user});

  @override
  Widget build(BuildContext context) {
    final name = user?['name'] ?? '사용자';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '안녕하세요, $name님!',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '오늘도 한 걸음 더 성장하셨네요! 🌱',
          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
      ],
    );
  }
}
