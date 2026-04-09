import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_user_app/core/supabase_service.dart';
import 'package:flutter_user_app/screens/login_screen.dart';
import 'package:flutter_user_app/screens/dashboard_screen.dart';
import 'package:flutter_user_app/core/design_system.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // [1] 초기 세션 확인을 위한 Future (최대 2초만 대기)
    return FutureBuilder<void>(
      future: Future.delayed(const Duration(seconds: 2)),
      builder: (context, timeoutSnapshot) {
        return StreamBuilder<AuthState>(
          stream: Supabase.instance.client.auth.onAuthStateChange,
          builder: (context, snapshot) {
            final session = Supabase.instance.client.auth.currentSession;
            final isWaiting = snapshot.connectionState == ConnectionState.waiting;

            // 세션이 이미 발견됨
            if (session != null) {
              return _buildUserStatusChecker();
            }

            // 2초가 지났거나, 스트림이 '세션 없음'을 확인해준 경우
            if (timeoutSnapshot.connectionState == ConnectionState.done || !isWaiting) {
              return const LoginScreen();
            }

            // 아직 2초 전이고 스트림도 대기 중이라면 스피너
            return const Scaffold(
              body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            );
          },
        );
      },
    );
  }

  Widget _buildUserStatusChecker() {
    return FutureBuilder<String>(
      future: SupabaseService.reloadUserStatus(),
      builder: (context, statusSnapshot) {
        // ... (이하 기존 코드 조각 재구성) ...
        if (statusSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                   CircularProgressIndicator(color: AppColors.primary),
                   SizedBox(height: 16),
                   Text('Verifying user status...', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          );
        }
        if (statusSnapshot.hasError) return const LoginScreen();
        final String status = statusSnapshot.data ?? 'pending';
        return status == 'approved' ? const DashboardScreen() : const LoginScreen();
      },
    );
  }
}
