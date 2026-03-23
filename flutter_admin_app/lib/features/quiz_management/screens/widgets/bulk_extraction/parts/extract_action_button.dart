import 'package:flutter/material.dart';

class ExtractActionButton extends StatelessWidget {
  final bool isLoading;
  final bool isFilterComplete;
  final VoidCallback onExtractPressed;
  final Color primaryColor;
  final Color surfaceDark;

  const ExtractActionButton({
    super.key,
    required this.isLoading,
    required this.isFilterComplete,
    required this.onExtractPressed,
    required this.primaryColor,
    required this.surfaceDark,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: isLoading || !isFilterComplete ? null : onExtractPressed,
      icon: Icon(
        Icons.auto_awesome,
        size: 18,
        color: isFilterComplete ? primaryColor : Colors.white24,
      ),
      label: Text(
        'PDF 추출',
        style: TextStyle(
          color: isFilterComplete ? Colors.white : Colors.white24,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: surfaceDark,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isFilterComplete ? Colors.white10 : Colors.transparent,
          ),
        ),
      ),
    );
  }
}
