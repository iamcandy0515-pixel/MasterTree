import 'package:flutter/material.dart';

class TagHintInput extends StatelessWidget {
  final String? initialHint;
  final Function(String) onChanged;

  const TagHintInput({
    super.key,
    this.initialHint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '이 부위의 퀴즈 힌트',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: onChanged,
          controller: TextEditingController(text: initialHint)
            ..selection = TextSelection.collapsed(
              offset: (initialHint ?? '').length,
            ),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          maxLines: 2,
          decoration: InputDecoration(
            hintText: '문제가 나왔을 때 사용자에게 보여줄 힌트를 입력하세요.',
            hintStyle: const TextStyle(
              color: Colors.white24,
              fontSize: 12,
            ),
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
