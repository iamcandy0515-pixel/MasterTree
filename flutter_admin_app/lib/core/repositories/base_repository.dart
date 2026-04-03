import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_admin_app/core/globals.dart';
import 'package:flutter_admin_app/features/auth/screens/login_screen.dart';
import 'package:flutter_admin_app/core/api/node_api.dart';

abstract class BaseRepository {
  final String baseUrl;

  BaseRepository()
      : baseUrl = NodeApi.baseUrl;

  /// Auth Token을 포함한 공통 헤더 생성 (SharedPreferences DTC 전용)
  Future<Map<String, String>> getHeaders() async {
    String token = '';
    try {
      final prefs = await SharedPreferences.getInstance();
      // 🔥 [FTF] Only trust Direct Token Channel (DTC)
      token = prefs.getString('access_token') ?? '';
      
      // ⚠️ Removed unstable Supabase.instance.client.auth.currentSession access 🛡️
    } catch (e) {
      debugPrint('❌ Header error (Safe-Skip): $e');
    }

    return <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// 인증 관련 에러 체크 (401, 403 발생 시 자동 로그아웃)
  void checkAuthError(int statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      // Best effort sign out
      try { Supabase.instance.client.auth.signOut(); } catch (_) {}
      
      // Clear token from prefs on auth error
      SharedPreferences.getInstance().then((prefs) {
        prefs.remove('access_token');
      });

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

  /// 이미지 서버 프록시 URL 생성 (정적 유틸리티)
  static String staticProxyUrl(
    String url, {
    String? baseUrl,
    int? width,
    int? height,
  }) {
    if (url.contains('drive.google.com') || url.startsWith('http')) {
      final base = baseUrl ?? NodeApi.baseUrl;
      String proxyUrl = '$base/uploads/proxy?url=${Uri.encodeComponent(url)}';
      if (width != null) proxyUrl += '&w=$width';
      if (height != null) proxyUrl += '&h=$height';
      return proxyUrl;
    }
    return url;
  }
}
