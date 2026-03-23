import 'package:flutter/material.dart';

class ImageManagerLoading extends StatelessWidget {
  final bool isUploading;
  static const primaryColor = Color(0xFF2BEE8C);

  const ImageManagerLoading({super.key, required this.isUploading});

  @override
  Widget build(BuildContext context) {
    if (!isUploading) return const SizedBox.shrink();

    return Center(
      child: Column(
        children: const [
          LinearProgressIndicator(color: primaryColor),
          SizedBox(height: 8),
          Text(
            '이미지 처리 중...',
            style: TextStyle(color: primaryColor, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
