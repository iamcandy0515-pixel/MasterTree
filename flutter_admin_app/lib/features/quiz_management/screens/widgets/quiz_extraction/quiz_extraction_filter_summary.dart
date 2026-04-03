import 'package:flutter/material.dart';

class QuizExtractionFilterSummary extends StatelessWidget {
  final String? subject;
  final int? year;
  final int? round;

  const QuizExtractionFilterSummary({
    super.key,
    dynamic subject,
    dynamic year,
    dynamic round,
  })  : subject = (subject == null) ? null : subject.toString(),
        year = (year == null) ? null : int.tryParse(year.toString()),
        round = (round == null) ? null : int.tryParse(round.toString());

  @override
  Widget build(BuildContext context) {
    if (subject == null && year == null && round == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF102219),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _buildItem(Icons.bookmark_active, subject ?? '과목미지정'),
          _buildItem(Icons.calendar_today, year != null ? '$year년' : '연도미상'),
          _buildItem(Icons.history, round != null ? '$round회차' : '회차정보없음'),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF2BEE8C).withOpacity(0.8)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
