import 'package:flutter/material.dart';
import '../../../../core/design_system.dart';

class LoginActionButtons extends StatelessWidget {
  final VoidCallback onLogin;

  const LoginActionButtons({
    super.key,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onLogin,
            child: const Text(
              '입장하기',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
