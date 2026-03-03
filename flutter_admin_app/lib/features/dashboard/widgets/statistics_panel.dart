import 'package:flutter/material.dart';

class StatisticsPanel extends StatelessWidget {
  final int totalTrees;
  final int completedTrees;
  final int incompleteTrees;

  const StatisticsPanel({
    super.key,
    required this.totalTrees,
    required this.completedTrees,
    required this.incompleteTrees,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          _buildStatItem('전체 수목', '$totalTrees', '종', Colors.white),
          const SizedBox(width: 48),
          _buildStatItem('완료', '$completedTrees', '건', const Color(0xFFCCFF00)),
          const SizedBox(width: 48),
          _buildStatItem('미완료', '$incompleteTrees', '건', Colors.orangeAccent),
          const Spacer(),
          // Progress Bar
          SizedBox(
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '진척률 ${(totalTrees > 0 ? (completedTrees / totalTrees * 100).toStringAsFixed(1) : '0')}%',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: totalTrees > 0 ? completedTrees / totalTrees : 0,
                  backgroundColor: Colors.white12,
                  color: const Color(0xFFCCFF00),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: TextStyle(color: color.withOpacity(0.7), fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }
}
