import 'package:flutter/material.dart';

class BulkExtractionEmptyView extends StatelessWidget {
  const BulkExtractionEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.quiz_outlined, size: 64, color: Colors.white10),
          SizedBox(height: 16),
          Text(
            '추출된 퀴즈가 없습니다.\nPDF를 추출해주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
