import 'package:flutter/material.dart';

class AIReviewResultDialog extends StatelessWidget {
  final bool isAligned;
  final int score;
  final String reviewNotes;
  final List<dynamic> suggestions;
  final VoidCallback onApplyFirstSuggestion;
  final Color primaryColor;
  final Color cardDark;

  const AIReviewResultDialog({
    super.key,
    required this.isAligned,
    required this.score,
    required this.reviewNotes,
    required this.suggestions,
    required this.onApplyFirstSuggestion,
    required this.primaryColor,
    required this.cardDark,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: cardDark,
      title: Row(
        children: [
          Icon(
            isAligned ? Icons.check_circle : Icons.warning,
            color: isAligned ? primaryColor : Colors.orangeAccent,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              isAligned ? 'AI 검수 완료 (일치)' : 'AI 검수 완료 (불일치/이슈)',
              style: const TextStyle(color: Colors.white, fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '신뢰도 점수: $score / 100',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Text(
              '검토 의견:\n$reviewNotes',
              style: const TextStyle(color: Colors.white70),
            ),
            if (suggestions.isNotEmpty && !isAligned) ...[
              const SizedBox(height: 16),
              Text(
                '수정 제안:',
                style: TextStyle(
                  color: Colors.orange[300],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...suggestions.map<Widget>(
                (dynamic s) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    '- $s',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            '닫기',
            style: TextStyle(color: Colors.white54),
          ),
        ),
        if (!isAligned && suggestions.isNotEmpty)
          TextButton(
            onPressed: () {
              onApplyFirstSuggestion();
              Navigator.pop(context);
            },
            child: Text(
              '첫번째 제안으로 교체',
              style: TextStyle(color: primaryColor),
            ),
          ),
      ],
    );
  }
}
