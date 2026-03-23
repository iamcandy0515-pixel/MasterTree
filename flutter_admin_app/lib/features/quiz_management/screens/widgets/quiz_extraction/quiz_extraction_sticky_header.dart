import 'dart:ui';
import 'package:flutter/material.dart';

class QuizExtractionStickyHeader extends StatelessWidget {
  final VoidCallback onBack;
  final String title;
  final Color backgroundColor;

  const QuizExtractionStickyHeader({
    super.key,
    required this.onBack,
    this.title = '기출문제 연동',
    this.backgroundColor = const Color(0xFF102219),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Glassmorphism Effect
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            bottom: 16,
            left: 20,
            right: 20,
          ),
          decoration: BoxDecoration(
            color: backgroundColor.withOpacity(0.7), // Semi-transparent
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 36), // Balance the back button
            ],
          ),
        ),
      ),
    );
  }
}
