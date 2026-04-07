import 'package:flutter/material.dart';
import '../../../core/design_system.dart';

class StatSummaryCard extends StatelessWidget {
  final String title;
  final Map<String, dynamic> data;
  final Color accentColor;
  final IconData icon;

  const StatSummaryCard({
    super.key,
    required this.title,
    required this.data,
    required this.accentColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final int total = (data['totalCount'] as num?)?.toInt() ?? 0;
    final int solved = (data['solvedCount'] as num?)?.toInt() ?? 0;
    final int correct = (data['correctCount'] as num?)?.toInt() ?? 0;
    // final int wrong = (data['wrongCount'] as num?)?.toInt() ?? 0; // Removed unused
    final double progress = total > 0 ? (correct / total) : 0.0; // Mastery rate based on total questions
    final double accuracy = solved > 0 ? (correct / solved) * 100 : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '지식 습득률 (Mastery: $correct / $total)',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
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
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.05),
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _SimpleStat(label: '습득 완료', value: '$correct', color: Colors.greenAccent),
              _SimpleStat(label: '도전 중', value: '${solved - correct}', color: Colors.orangeAccent),
              _SimpleStat(
                label: '정답률(최근)',
                value: '${accuracy.toStringAsFixed(0)}%',
                color: Colors.white,
              ),
            ],
          ),
        ],
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
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
