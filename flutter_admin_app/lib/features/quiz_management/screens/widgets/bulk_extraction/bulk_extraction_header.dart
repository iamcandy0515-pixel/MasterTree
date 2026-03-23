import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../viewmodels/bulk_extraction_viewmodel.dart';

class BulkExtractionHeader extends StatelessWidget {
  final BulkExtractionViewModel vm;
  final Function(Map<String, int>) onSaveResult;

  const BulkExtractionHeader({
    super.key,
    required this.vm,
    required this.onSaveResult,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF102219),
      elevation: 0,
      title: Text(
        '기출문제 추출 (일괄)',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: vm.isLoading || vm.extractedQuizzes.isEmpty
              ? null
              : () => _confirmSave(context),
          icon: const Icon(
            Icons.cloud_upload,
            size: 18,
            color: Colors.white70,
          ),
          label: const Text(
            'DB 등록',
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: Colors.white10, height: 1),
      ),
    );
  }

  void _confirmSave(BuildContext context) {
    showDialog(
      context: context,
      builder: (dctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2E24),
        title: const Text('일괄 DB 등록', style: TextStyle(color: Colors.white, fontSize: 18)),
        content: const Text(
          '편집한 모든 문항을 데이터베이스에 등록하시겠습니까?\n완료 후 로컬 백업은 삭제됩니다.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dctx),
            child: const Text('취소', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dctx);
              final stats = await vm.saveAllToDatabase();
              onSaveResult(stats);
            },
            child: const Text(
              '등록하기',
              style: TextStyle(color: Color(0xFF2BEE8C), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
