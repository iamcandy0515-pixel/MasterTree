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
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        final session = snapshot.data?.session;
        if (session == null) {
          return const LoginScreen();
        }

        // 세션이 있는 경우, 서버에서 유저 상태(status)를 최종 확인
        return FutureBuilder<String>(
          future: SupabaseService.reloadUserStatus(),
          builder: (context, statusSnapshot) {
            if (statusSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              );
            }

            final String status = statusSnapshot.data ?? 'pending';
            if (status == 'approved') {
              return const DashboardScreen();
            } else {
              // 승인되지 않은 상태라면 자동으로 로그아웃 처리하고 로그인 화면으로 유도
              // UI 빌드 도중 signOut을 호출하면 경고가 발생할 수 있으므로 
              // 포스트 프레임 콜백이나 별도 로직으로 처리하는 것이 이상적이나, 
              // 여기서는 일단 LoginScreen을 보여주고 내부에서 처리하도록 함.
              return const LoginScreen();
            }
          },
        );
      },
    );
  }
}
