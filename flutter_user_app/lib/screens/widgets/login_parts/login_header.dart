import 'package:flutter/material.dart';
import '../../../../core/design_system.dart';

class LoginHeader extends StatelessWidget {
  final VoidCallback onClearData;

  const LoginHeader({
    super.key,
    required this.onClearData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.forest, color: AppColors.primary, size: 80),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Flexible(
              child: Text(
                'Master Tree User',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onClearData,
              icon: const Icon(Icons.delete_outline, size: 20),
              color: AppColors.textMuted,
              tooltip: '저장된 테스트 데이터 삭제',
            ),
          ],
        ),
      ],
    );
  }
}
