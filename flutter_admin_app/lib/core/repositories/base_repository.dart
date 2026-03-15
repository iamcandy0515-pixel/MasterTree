import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_admin_app/core/globals.dart';
import 'package:flutter_admin_app/features/auth/screens/login_screen.dart';

abstract class BaseRepository {
  final String baseUrl;

  BaseRepository()
      : baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000/api';

  /// Auth Token을 포함한 공통 헤더 생성
  Future<Map<String, String>> getHeaders() async {
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// 인증 관련 에러 체크 (401, 403 발생 시 자동 로그아웃)
  void checkAuthError(int statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      Supabase.instance.client.auth.signOut();
      final context = globalNavigatorKey.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 만료되었습니다. 다시 로그인 해주세요.')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
      throw Exception('인증 만료 (서버 오류: $statusCode)');
    }
  }
}
