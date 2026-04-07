import 'package:flutter/material.dart';

/// 관리자 앱 디자인 시스템 컬러
const Color primaryColor = Color(0xFF2BEE8C);
const Color backgroundDark = Color(0xFF102219);
const Color surfaceDark = Color(0xFF1A2E24);
const Color textMuted = Colors.grey;

/// 종합 탭: 전체적인 성과 요약 (사용자 앱 UI 이식)
class GeneralStatsTab extends StatelessWidget {
  final Map<String, dynamic> stats;
  const GeneralStatsTab({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          const SizedBox(height: 24),
          StatCard(
            title: '수목 퀴즈 학습 요약',
            data: (stats['quiz'] as Map<String, dynamic>? ?? <String, dynamic>{}),
            accentColor: primaryColor,
            icon: Icons.school,
          ),
          const SizedBox(height: 16),
          StatCard(
            title: '기출 문제 학습 요약',
            data: (stats['pastExam'] as Map<String, dynamic>? ?? <String, dynamic>{}),
            accentColor: Colors.orangeAccent,
            icon: Icons.history_edu,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final dynamic user = stats['user'];
    final dynamic name = user?['name'] ?? '사용자';
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
          '오늘도 한 걸음 더 성장하셨네요. 💪',
          style: TextStyle(color: textMuted, fontSize: 14),
        ),
      ],
    );
  }
}

/// 학습 카드 위젯 (사용자 앱 UI 이식)
class StatCard extends StatelessWidget {
  final String title;
  final Map<String, dynamic> data;
  final Color accentColor;
  final IconData icon;

  const StatCard({
    super.key,
    required this.title,
    required this.data,
    required this.accentColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final int total = (data['totalCount'] as int? ?? 0);
    final int solved = (data['solvedCount'] as int? ?? 0);
    final int correct = (data['correctCount'] as int? ?? 0);
    final int wrong = (data['wrongCount'] as int? ?? 0);
    final double progress = total > 0 ? solved / total : 0.0;
    final double accuracy = solved > 0 ? (correct / solved) * 100 : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(13)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProgressInfo(solved, total, progress, accentColor),
          const SizedBox(height: 8),
          _buildProgressBar(progress, accentColor),
          const SizedBox(height: 24),
          Row(
            children: [
              _SimpleStat(
                label: '정답',
                value: '$correct',
                color: Colors.greenAccent,
              ),
              _SimpleStat(
                label: '오답',
                value: '$wrong',
                color: Colors.redAccent,
              ),
              _SimpleStat(
                label: '정답률',
                value: '${accuracy.toStringAsFixed(0)}%',
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressInfo(
    int solved,
    int total,
    double progress,
    Color accentColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '진행률 ($solved / $total)',
          style: const TextStyle(color: textMuted, fontSize: 12),
        ),
        Text(
          '${(progress * 100).toStringAsFixed(1)}%',
          style: TextStyle(
            color: accentColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double progress, Color accentColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 10,
        backgroundColor: Colors.white.withAlpha(13),
        valueColor: AlwaysStoppedAnimation<Color>(accentColor),
      ),
    );
  }
}

class _SimpleStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SimpleStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}
