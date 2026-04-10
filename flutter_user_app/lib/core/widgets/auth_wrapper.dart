import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/design_system.dart';
import '../../screens/login_screen.dart';
import '../../screens/dashboard_screen.dart';
import '../../viewmodels/auth_viewmodel.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()..initialize()),
      ],
      child: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          final session = snapshot.data?.session;

          // 1. 세션이 없으면 로그인 화면으로 이동
          if (session == null) {
            return const LoginScreen();
          }

          // 2. 세션이 있다면 AuthViewModel을 통해 사용자 상태 관찰 (깜빡임 방지)
          return Consumer<AuthViewModel>(
            builder: (context, vm, child) {
              final status = vm.userStatus;

              // 세션 로딩 중 (초기 1회)
              if (status == 'pending' && vm.isCheckingServer) {
                return _buildLoadingScreen('사용자 권한을 확인하고 있습니다...');
              }

              // 세션 불일치(중복 로그인) 또는 만료 시 로그인 화면으로 튕김 처리
              if (status == 'expired') {
                return const LoginScreen();
              }

              // 모든 검증 통과 시 대시보드 진입
              return const DashboardScreen();
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingScreen(String message) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
