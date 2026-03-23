import 'package:flutter/material.dart';

class FileIdInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final Color primaryColor;
  final Color surfaceDark;

  const FileIdInput({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.primaryColor,
    required this.surfaceDark,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: '드라이브 파일 ID 또는 파일명',
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
        prefixIcon: Icon(
          Icons.description,
          color: primaryColor,
          size: 18,
        ),
        filled: true,
        fillColor: surfaceDark,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: onChanged,
    );
  }
}
