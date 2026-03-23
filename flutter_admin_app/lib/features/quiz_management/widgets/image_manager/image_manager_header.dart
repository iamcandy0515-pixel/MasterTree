import 'package:flutter/material.dart';

class ImageManagerHeader extends StatelessWidget {
  final String field;
  static const primaryColor = Color(0xFF2BEE8C);

  const ImageManagerHeader({super.key, required this.field});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.image_outlined, color: primaryColor),
        const SizedBox(width: 10),
        Text(
          '${field == 'question' ? '문제' : '해설'} 이미지 관리',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ],
    );
  }
}
