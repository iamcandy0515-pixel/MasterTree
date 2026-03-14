import 'package:flutter/material.dart';
import '../../../core/design_system.dart';

class ComparisonDataCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content1;
  final String content2;
  final String tree1Name;
  final String tree2Name;

  const ComparisonDataCard({
    super.key,
    required this.icon,
    required this.title,
    required this.content1,
    required this.content2,
    required this.tree1Name,
    required this.tree2Name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.textMuted, size: 18),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildDataColumn(tree1Name, content1)),
                Container(
                  width: 1,
                  color: Colors.white10,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                Expanded(child: _buildDataColumn(tree2Name, content2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataColumn(String treeName, String value) {
    final displayValue = (value.isEmpty || value == '상세 정보가 없습니다.' || value == '정보가 없습니다.') 
        ? '정보가 없습니다.' 
        : value;
    final isNone = displayValue == '정보가 없습니다.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          treeName,
          style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          displayValue,
          style: TextStyle(
            color: isNone ? AppColors.textMuted : Colors.white,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
