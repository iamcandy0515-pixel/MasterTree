import 'package:flutter/material.dart';

class QuizExtractionFilterSummary extends StatelessWidget {
  final String? subject;
  final int? year;
  final int? round;
  final Color primaryColor;

  const QuizExtractionFilterSummary({
    super.key,
    this.subject,
    this.year,
    this.round,
    this.primaryColor = const Color(0xFF2BEE8C),
  });

  @override
  Widget build(BuildContext context) {
    if (subject == null && year == null && round == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.filter_list, color: primaryColor, size: 18),
              const SizedBox(width: 8),
              const Text(
                '검색필터',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          if (subject != null) _buildTag(subject!),
          if (year != null) _buildTag('$year년'),
          if (round != null) _buildTag('$round회'),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
