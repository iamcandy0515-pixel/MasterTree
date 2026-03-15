import 'package:flutter/material.dart';

class QuizDetailHeader extends StatelessWidget {
  final String subject;
  final String year;
  final String round;
  final String questionNo;

  const QuizDetailHeader({
    super.key,
    required this.subject,
    required this.year,
    required this.round,
    required this.questionNo,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2BEE8C);
    const surfaceDark = Color(0xFF1A2E24);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(child: _buildInfoItem('과목', subject, primaryColor)),
          _buildDivider(),
          Expanded(child: _buildInfoItem('년도', '$year년', primaryColor)),
          _buildDivider(),
          Expanded(child: _buildInfoItem('회차', '$round회', primaryColor)),
          _buildDivider(),
          Expanded(child: _buildInfoItem('문제번호', questionNo, primaryColor)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 24, width: 1, color: Colors.white10);
  }

  Widget _buildInfoItem(String label, String value, Color primaryColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: primaryColor,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
