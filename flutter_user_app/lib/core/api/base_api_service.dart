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

  static dynamic decodeResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      debugPrint('API Error: ${response.statusCode} - ${response.body}');
      throw Exception('API Error: ${response.body}');
    }
  }

  static Future<dynamic> get(Uri url) async {
    try {
      final response = await http.get(url, headers: getHeaders());
      return decodeResponse(response);
    } catch (e) {
      debugPrint('ApiService.get Error: $e');
      rethrow;
    }
  }

  static Future<dynamic> post(Uri url, dynamic body) async {
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
