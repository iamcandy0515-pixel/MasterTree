import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/design_system.dart';
import '../../screens/login_screen.dart';
import '../../screens/dashboard_screen.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../core/supabase_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // [핵심] AuthViewModel 인스턴스를 최상위에서 한 번만 생성하여 안정화
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          final session = snapshot.data?.session;

          // 1. 세션이 없으면 로그인 화면으로 이동
          if (session == null) {
            return const LoginScreen();
          }

          // 2. 세션이 있다면 사용자 상태(중복 로그인, 차단 여부 등) 서버 실시간 검증
          return FutureBuilder<String>(
            future: SupabaseService.reloadUserStatus(),
            builder: (context, statusSnapshot) {
              if (statusSnapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingScreen('사용자 권한을 확인하고 있습니다...');
              }

              final status = statusSnapshot.data ?? 'pending';

              // 세션 불일치(중복 로그인) 시 로그인 화면으로 튕김 처리
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
