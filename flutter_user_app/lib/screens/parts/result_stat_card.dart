import 'package:flutter/material.dart';
import '../core/design_system.dart';

class ResultStatCard extends StatelessWidget {
  final int solvedCount;
  final int correctCount;
  final double avgHints;
  final int totalHints;
  final Color borderColor;

  const ResultStatCard({
    super.key,
    required this.solvedCount,
    required this.correctCount,
    required this.avgHints,
    required this.totalHints,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          _buildStatRow(
            '총 대면한 문제',
            '$solvedCount 문제',
          ),
          const Divider(color: Colors.white12, height: 24),
          _buildStatRow(
            '정답 개수',
            '$correctCount 개',
            valueColor: AppColors.primary,
          ),
          const Divider(color: Colors.white12, height: 24),
          _buildStatRow(
            '평균 사용 힌트',
            '${avgHints.toStringAsFixed(1)} 개',
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '(총 힌트 사용횟수: $totalHints)',
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
