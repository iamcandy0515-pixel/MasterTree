import 'package:flutter/material.dart';

class ExplanationInputSection extends StatelessWidget {
  final TextEditingController controller;
  final bool isReviewing;
  final bool canReview;
  final VoidCallback onReview;
  final Color primaryColor;

  const ExplanationInputSection({
    super.key,
    required this.controller,
    required this.isReviewing,
    required this.canReview,
    required this.onReview,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                '정답 및 해설',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: !canReview || isReviewing ? null : onReview,
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: isReviewing
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF2BEE8C),
                      ),
                    )
                  : const Text(
                      'AI 검수',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
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
            hintText: '정답 및 해설이 여기에 표시됩니다.',
            hintStyle: TextStyle(color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }
}
