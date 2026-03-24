import 'package:flutter/material.dart';

class ResultTitleSection extends StatelessWidget {
  final IconData icon;
  final Color titleColor;
  final String title;
  final String description;

  const ResultTitleSection({
    super.key,
    required this.icon,
    required this.titleColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 80,
          color: titleColor,
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
