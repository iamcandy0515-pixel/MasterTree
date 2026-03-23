import 'package:flutter/material.dart';

class BulkActionHeader extends StatelessWidget {
  final bool isProcessing;
  final bool isEmpty;
  final bool hasRecommendations;
  final VoidCallback onBulkRecommend;
  final VoidCallback onSaveAll;

  static const primaryColor = Color(0xFF2BEE8C);

  const BulkActionHeader({
    super.key,
    required this.isProcessing,
    required this.isEmpty,
    required this.hasRecommendations,
    required this.onBulkRecommend,
    required this.onSaveAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: isProcessing || isEmpty ? null : onBulkRecommend,
            icon: const Icon(Icons.flash_on, size: 18),
            label: const Text('일괄 유사문제 추출(page단위)'),
            style: TextButton.styleFrom(foregroundColor: primaryColor),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: isProcessing || !hasRecommendations ? null : onSaveAll,
            icon: const Icon(Icons.save, size: 18),
            label: const Text('일괄 저장'),
            style: TextButton.styleFrom(foregroundColor: primaryColor),
          ),
        ],
      ),
    );
  }
}
