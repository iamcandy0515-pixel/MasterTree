import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/design_system.dart';
import '../../../viewmodels/auth_viewmodel.dart';

class LoginStatusOverlay extends StatelessWidget {
  const LoginStatusOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AuthViewModel, ({bool isLoading, bool isChecking})>(
      selector: (_, vm) => (
        isLoading: vm.isLoading,
        isChecking: vm.isCheckingServer,
      ),
      builder: (context, status, _) {
        return Stack(
          children: [
            if (status.isChecking)
              const Positioned(
                top: 230, // Adjust relative to title
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    '사용자 정보 확인 중...',
                    style: TextStyle(color: AppColors.primary, fontSize: 12),
                  ),
                ),
              ),
            if (status.isLoading)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
          ],
        );
      },
    );
  }
}
