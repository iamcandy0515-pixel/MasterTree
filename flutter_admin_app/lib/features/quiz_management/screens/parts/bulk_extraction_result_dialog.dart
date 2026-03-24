import 'package:flutter/material.dart';

class BulkExtractionResultDialog extends StatelessWidget {
  final Map<String, int> stats;
  final Color surfaceDark;

  const BulkExtractionResultDialog({
    super.key,
    required this.stats,
    required this.surfaceDark,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: surfaceDark,
      title: const Text(
        'DB 등록 결과',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '■ 총 문항: ${stats['total']}건',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            '■ 성공: ${stats['success']}건',
            style: const TextStyle(color: Color(0xFF2BEE8C)),
          ),
          const SizedBox(height: 4),
          Text(
            '■ 실패: ${stats['failed']}건',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            '확인',
            style: TextStyle(color: Color(0xFF2BEE8C)),
          ),
        ),
      ],
    );
  }
}
