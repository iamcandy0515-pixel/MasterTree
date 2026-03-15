import 'package:flutter/material.dart';

class QuizEmptyState extends StatelessWidget {
  final String message;
  const QuizEmptyState({super.key, this.message = '조건에 맞는 기출문제가 없습니다.'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, color: Colors.white24, size: 64),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.white54, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
