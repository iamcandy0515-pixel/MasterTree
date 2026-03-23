import 'package:flutter/material.dart';

class BulkQuizListItem {
  static const primaryColor = Color(0xFF2BEE8C);
  static const aiColor = Color(0xFF00D1FF);

  static Widget build({
    required Map<String, dynamic> quiz,
    required String fullText,
    required int status,
    required int displayCount,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Row(
          children: [
            Text(
              'Q${quiz['question_number']}',
              style: const TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                fullText.replaceAll(RegExp(r'^\d+[\.\)]?\s*'), ''),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _buildStatusIcon(status, displayCount),
          ],
        ),
      ),
    );
  }

  static Widget _buildStatusIcon(int status, int recCount) {
    if (status == 1) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: aiColor),
      );
    }
    if (status == 2) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: primaryColor, size: 16),
          const SizedBox(width: 4),
          Text(
            '$recCount',
            style: const TextStyle(color: primaryColor, fontSize: 11),
          ),
        ],
      );
    }
    if (status == 3) {
      return const Icon(Icons.error_outline, color: Colors.redAccent, size: 16);
    }
    return const Icon(Icons.hourglass_empty, color: Colors.white24, size: 16);
  }
}
