import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BaseApiService {
  static DateTime? _lastSessionCheck;

  static Map<String, String> getHeaders() {
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken ?? '';
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Optional: Real-time session validation before critical requests
  static Future<void> validateSession() async {
    final now = DateTime.now();
    if (_lastSessionCheck != null && now.difference(_lastSessionCheck!).inMinutes < 5) return;
    
    _lastSessionCheck = now;
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return;

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final Map<String, dynamic>? data = await Supabase.instance.client
            .from('users')
            .select<PostgrestMap?>('last_session_id')
            .eq('auth_id', user.id)
            .maybeSingle();

        if (data != null) {
          final String token = session.accessToken;
          final String shortId = token.length > 20 ? token.substring(0, 20) : token;
          final String? dbId = data['last_session_id']?.toString();
          
          if (dbId != null && dbId != shortId) {
             debugPrint('--- BASE_API: Session collision detected during request');
             await Supabase.instance.client.auth.signOut();
             throw Exception('SESSION_ALREADY_LOGGED_IN');
          }
        }
      }
    } catch (e) {
      if (e.toString().contains('SESSION_ALREADY_LOGGED_IN')) rethrow;
      debugPrint('--- BASE_API: Session check failed (ignoring): $e');
    }
  }

  static Map<String, dynamic> decodeResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return <String, dynamic>{'success': true, 'data': decoded};
    } else {
      debugPrint('API Error: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 401) {
        // 토큰 만료 또는 타 기기 로그인으로 인한 무효화 시 로그아웃
        Supabase.instance.client.auth.signOut();
      }
      throw Exception('API Error: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> get(Uri url) async {
    try {
      await validateSession();
      final response = await http.get(url, headers: getHeaders());
      return decodeResponse(response);
    } catch (e) {
      debugPrint('ApiService.get Error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> post(Uri url, dynamic body) async {
    try {
      await validateSession();
      final response = await http.post(
        url,
        headers: getHeaders(),
        body: jsonEncode(body),
      );
      return decodeResponse(response);
    } catch (e) {
      debugPrint('ApiService.post Error: $e');
      rethrow;
    }
  }
}
