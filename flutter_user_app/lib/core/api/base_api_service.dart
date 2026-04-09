import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BaseApiService {
  static Map<String, String> getHeaders() {
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken ?? '';
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Map<String, dynamic> decodeResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return Map<String, dynamic>.from(decoded as Map);
    } else {
      debugPrint('API Error: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 401) {
        // 토큰 만료 또는 무효 시 로그아웃 처리
        Supabase.instance.client.auth.signOut();
      }
      throw Exception('API Error: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> get(Uri url) async {
    try {
      final response = await http.get(url, headers: getHeaders());
      return decodeResponse(response);
    } catch (e) {
      debugPrint('ApiService.get Error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> post(Uri url, dynamic body) async {
    try {
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
