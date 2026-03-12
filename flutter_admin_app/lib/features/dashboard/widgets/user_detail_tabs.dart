import 'package:flutter/material.dart';

/// 종합 탭: 전체적인 성과 요약
class GeneralStatsTab extends StatelessWidget {
  final Map<String, dynamic> stats;
  const GeneralStatsTab({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final quiz = stats['quiz'] ?? {};
    final exam = stats['pastExam'] ?? {};
    
    final int totalSolved = (quiz['solvedCount'] ?? 0) + (exam['solvedCount'] ?? 0);
    final int totalCorrect = (quiz['correctCount'] ?? 0) + (exam['correctCount'] ?? 0);
    final double accuracy = totalSolved > 0 ? (totalCorrect / totalSolved) * 100 : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildSummaryBox('전체 평균 정답률', '${accuracy.toStringAsFixed(1)}%', Colors.amberAccent),
          const SizedBox(height: 16),
          _buildSummaryBox('총 해결 문항 수', '$totalSolved개', Colors.blueAccent),
          const SizedBox(height: 16),
          _buildSummaryBox('총 정답 수', '$totalCorrect개', Colors.greenAccent),
        ],
      ),
    );
  }

  Widget _buildSummaryBox(String label, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(13)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

/// 학습 영역별 진행률 카드 (수목퀴즈, 기출문제 공유)
class ProgressStatsTab extends StatelessWidget {
  final String title;
  final Map<String, dynamic> data;
  final Color accentColor;

  const ProgressStatsTab({
    super.key,
    required this.title,
    required this.data,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final int total = data['totalCount'] ?? 0;
    final int solved = data['solvedCount'] ?? 0;
    final int correct = data['correctCount'] ?? 0;
    final double progress = total > 0 ? solved / total : 0.0;
    final double accuracy = solved > 0 ? (correct / solved) * 100 : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildProgressSection('전체 학습 진행률', progress, accentColor, '$solved / $total'),
          const SizedBox(height: 32),
          _buildProgressSection('학습 정답률', accuracy / 100, Colors.greenAccent, '${accuracy.toStringAsFixed(1)}%'),
          const SizedBox(height: 32),
          Row(
            children: [
              _buildSimpleStat('정답', '$correct', Colors.greenAccent),
              const SizedBox(width: 12),
              _buildSimpleStat('오답', '${solved - correct}', Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(String label, double value, Color color, String trailing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            Text(trailing, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 12,
            backgroundColor: Colors.white.withAlpha(13),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2E24),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white30, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
