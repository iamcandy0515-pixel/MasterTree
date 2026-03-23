import 'package:flutter/material.dart';

class QuestionInputSection extends StatelessWidget {
  final TextEditingController controller;
  final String? aiDetermination;
  final Color primaryColor;

  const QuestionInputSection({
    super.key,
    required this.controller,
    this.aiDetermination,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '문제',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (aiDetermination != null) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '(AI 판별: $aiDetermination)',
                  style: TextStyle(color: primaryColor, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: null,
          minLines: 3,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: false,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 0,
            ),
            isDense: true,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintText: '문제 내용이 여기에 표시됩니다.',
            hintStyle: TextStyle(color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }
}
