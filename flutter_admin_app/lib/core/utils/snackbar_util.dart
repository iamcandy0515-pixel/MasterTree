import 'package:flutter/material.dart';

class SnackBarUtil {
  /// 플로팅(Floating) 스타일의 메시지를 화면에 출력합니다.
  static void showFloating(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    bool isError = false,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // 이전 메시지 즉시 제거
    scaffoldMessenger.removeCurrentSnackBar();

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.info_outline,
              color: isError ? Colors.orangeAccent : const Color(0xFF2BEE8C),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            backgroundColor ?? const Color(0xFF1A2E24), // surfaceDark
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: (isError ? Colors.orangeAccent : const Color(0xFF2BEE8C))
                .withOpacity(0.3),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 40), // 화면 하단에서 띄움
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
