import 'package:flutter/material.dart';

class QuizRelatedCard extends StatelessWidget {
  final List<Map<String, dynamic>> relatedQuizzes;
  final int currentPage;
  final bool isRecommending;
  final Function(int) onPageChanged;
  final Function(int) onRemoveRelated;
  final VoidCallback onAiRecommend;

  const QuizRelatedCard({
    super.key,
    required this.relatedQuizzes,
    required this.currentPage,
    required this.isRecommending,
    required this.onPageChanged,
    required this.onRemoveRelated,
    required this.onAiRecommend,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2BEE8C);
    const surfaceDark = Color(0xFF1A3E2F);
    const aiColor = Color(0xFF8B5CF6);
    const int itemsPerPage = 5;

    final int totalPages = (relatedQuizzes.length / itemsPerPage).ceil();
    final int displayPage = (currentPage >= totalPages && totalPages > 0) ? totalPages - 1 : currentPage;
    final int startIndex = displayPage * itemsPerPage;
    final int endIndex = (startIndex + itemsPerPage < relatedQuizzes.length) ? startIndex + itemsPerPage : relatedQuizzes.length;
    final visibleQuizzes = relatedQuizzes.isEmpty ? [] : relatedQuizzes.sublist(startIndex, endIndex);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: surfaceDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('?좎궗 臾몄젣 紐⑸줉 (${relatedQuizzes.length}嫄?', style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  if (isRecommending)
                    const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: primaryColor, strokeWidth: 2))
                  else
                    _buildAIAssistantButton('AI 異붿쿇', Icons.auto_awesome, onAiRecommend, aiColor),
                  if (relatedQuizzes.length > itemsPerPage) ...[
                    const SizedBox(width: 12),
                    IconButton(icon: const Icon(Icons.chevron_left, color: Colors.white), iconSize: 20, onPressed: displayPage > 0 ? () => onPageChanged(displayPage - 1) : null),
                    Text('${displayPage + 1} / $totalPages', style: const TextStyle(color: Colors.white, fontSize: 12)),
                    IconButton(icon: const Icon(Icons.chevron_right, color: Colors.white), iconSize: 20, onPressed: displayPage < totalPages - 1 ? () => onPageChanged(displayPage + 1) : null),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (relatedQuizzes.isEmpty)
             const Center(child: Text('?곌껐???좎궗 臾몄젣媛 ?놁뒿?덈떎.', style: TextStyle(color: Colors.white24, fontSize: 13)))
          else
            ...visibleQuizzes.map((quiz) => _buildRelatedItem(quiz, primaryColor)),
        ],
      ),
    );
  }

  Widget _buildRelatedItem(Map<String, dynamic> quiz, Color primaryColor) {
    final exam = quiz['quiz_exams'] as Map<String, dynamic>?;
    final year = exam?['year'] ?? '-';
    final round = exam?['round'] ?? '-';
    final qNo = quiz['question_number'] ?? '-';
    final category = quiz['quiz_categories']?['name'] ?? '-';

    String content = '';
    final blocks = quiz['content_blocks'] as List?;
    if (blocks != null && blocks.isNotEmpty) {
      final textBlock = blocks.firstWhere((b) => b is Map && b['type'] == 'text', orElse: () => null);
      if (textBlock != null) content = textBlock['content']?.toString().replaceAll('\n', ' ').trim() ?? '';
    }
    content = content.replaceAll(RegExp(r'^\d+[\.\)]?\s*'), '');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 130, padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text('$year??$round??$qNo踰?$category)', style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(content, style: const TextStyle(color: Colors.white, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
          IconButton(icon: const Icon(Icons.close, color: Colors.white38, size: 16), onPressed: () => onRemoveRelated(quiz['id'])),
        ],
      ),
    );
  }

  Widget _buildAIAssistantButton(String label, IconData icon, VoidCallback onPressed, Color aiColor) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: aiColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: aiColor.withOpacity(0.5))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: aiColor),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: aiColor, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

