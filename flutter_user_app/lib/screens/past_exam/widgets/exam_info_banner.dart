import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/design_system.dart';

class ExamInfoBanner extends StatelessWidget {
  final String subject;
  final String year;
  final String round;
  final String questionNo;

  const ExamInfoBanner({
    super.key,
    required this.subject,
    required this.year,
    required this.round,
    required this.questionNo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildInfoItem('과목', subject)),
          _buildDivider(),
          Expanded(child: _buildInfoItem('년도', '$year년')),
          _buildDivider(),
          Expanded(child: _buildInfoItem('회차', '$round회')),
          _buildDivider(),
          Expanded(child: _buildInfoItem('번호', questionNo)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 20, width: 1, color: Colors.white10);
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
