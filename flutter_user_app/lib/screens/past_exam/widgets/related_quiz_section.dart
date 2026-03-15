import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/design_system.dart';

class RelatedQuizSection extends StatelessWidget {
  final List<Map<String, dynamic>> similarQuizzes;

  const RelatedQuizSection({super.key, required this.similarQuizzes});

  @override
  Widget build(BuildContext context) {
    if (similarQuizzes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          '유사문제 없음',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: const Text(
          '유사문제',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '이 문제와 유사한 ${similarQuizzes.length}개의 문제가 있습니다.',
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 10,
            fontStyle: FontStyle.italic,
          ),
        ),
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 12),
        children: similarQuizzes.map((quiz) {
          return _buildRelatedQuizCard(quiz);
        }).toList(),
      ),
    );
  }

  Widget _buildRelatedQuizCard(Map<String, dynamic> quiz) {
    final exam = quiz['quiz_exams'] as Map<String, dynamic>?;
    final year = exam?['year'] ?? '-';
    final round = exam?['round'] ?? '-';
    final qNo = quiz['question_number'] ?? '-';
    final subject = quiz['quiz_categories']?['name'] ?? '-';

    final blocks = quiz['content_blocks'] as List<dynamic>?;
    String qText = '내용 없음';
    if (blocks != null && blocks.isNotEmpty) {
      final textBlock = blocks.firstWhere(
        (b) => b['type'] == 'text',
        orElse: () => {'content': ''},
      );
      qText = textBlock['content']?.toString() ?? '내용 없음';
    }
    qText = qText.replaceAll('\n', ' ').trim();
    qText = qText.replaceAll(RegExp(r'^\d+[\.\)]?\s*'), '');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 130,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$year년 $round회 $qNo번($subject)',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                qText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
