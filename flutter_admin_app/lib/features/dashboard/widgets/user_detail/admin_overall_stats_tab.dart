import 'package:flutter/material.dart';
import 'stats_colors.dart';
import 'stat_summary_card.dart';

/// 종합 학습 현황: 사용자 앱의 UI 레이아웃을 그대로 복제하여 연동
class AdminOverallStatsTab extends StatelessWidget {
  final Map<String, dynamic> stats;

  const AdminOverallStatsTab({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(),
          const SizedBox(height: 24),
          StatSummaryCard(
            title: '수목 퀴즈 학습 요약',
            data: Map<String, dynamic>.from(stats['quiz'] as Map? ?? <String, dynamic>{}),
            accentColor: StatsColors.quizAccent,
            icon: Icons.school,
          ),
          const SizedBox(height: 16),
          StatSummaryCard(
            title: '기출 문제 학습 요약',
            data: Map<String, dynamic>.from(stats['pastExam'] as Map? ?? <String, dynamic>{}),
            accentColor: StatsColors.examAccent,
            icon: Icons.history_edu,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    final Map<String, dynamic>? user = stats['user'] as Map<String, dynamic>?;
    final String name = user?['name']?.toString() ?? '사용자';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '관리자가 확인하는 $name님의 학습 성과',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '사용자의 꾸준한 성장을 응원해주세요! 🌱',
          style: TextStyle(color: StatsColors.textMuted, fontSize: 13),
        ),
      ],
    );
  }
}
