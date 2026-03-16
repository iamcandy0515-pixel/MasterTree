import 'package:flutter/material.dart';

class UserDeleteDialog extends StatelessWidget {
  final String userName;
  final VoidCallback onConfirm;

  const UserDeleteDialog({
    super.key,
    required this.userName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    const surfaceDark = Color(0xFF1E1E1E); // Custom local fallback or NeoColors.darkGray

    return AlertDialog(
      backgroundColor: surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        '사용자 삭제',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: Text(
        '삭제 시 사용자의 정보가 사라집니다. 그래도 삭제하시겠습니까?',
        style: TextStyle(color: Colors.white.withOpacity(0.7), height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소', style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: const Text(
            '확인',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  static void show(BuildContext context, String userName, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => UserDeleteDialog(userName: userName, onConfirm: onConfirm),
    );
  }
}

