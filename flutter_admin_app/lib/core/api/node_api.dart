import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_admin_app/core/globals.dart';
import 'package:flutter_admin_app/features/auth/screens/login_screen.dart';

class NodeApi {
  static String get baseUrl {
    // [1] 배포 환경이거나 브라우저 주소가 localhost가 아니면 무조건 리얼 서버 사용
    if (kReleaseMode || !Uri.base.toString().contains('localhost')) {
      return 'https://mastertree-api-final.vercel.app/api';
    }
    // [2] 로컬 테스트 환경일 때만 localhost 사용
    return dotenv.env['NODE_API_URL'] ?? 'http://localhost:5000/api';
  }

  /// Get headers with Auth Token
  static Future<Map<String, String>> _getHeaders() async {
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken ?? '';
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Global Error Handler for 401/403
  static void _checkAuthError(int statusCode) {
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

  static Future<List<dynamic>> getTrees() async {
    final headers = await _getHeaders();
    final resp = await http.get(Uri.parse('$baseUrl/trees'), headers: headers);

    if (resp.statusCode == 200) {
      final decoded = jsonDecode(resp.body);
      if (decoded is Map) {
        final json = Map<String, dynamic>.from(decoded);
        final data = json['data'];
        if (data is List) {
          return data.map((e) => e is Map ? Map<String, dynamic>.from(e) : e).toList();
        }
      }
      return [];
    } else {
      _checkAuthError(resp.statusCode);
      throw Exception('Failed to fetch trees: ${resp.body}');
    }
  }

  static Future<String?> searchGoogleImage(
    String treeName,
    String imageType,
  ) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl/external/google-images');

    final resp = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({'treeName': treeName, 'imageType': imageType}),
    );

    if (resp.statusCode == 200) {
      final decoded = jsonDecode(resp.body);
      if (decoded is Map) {
        final json = Map<String, dynamic>.from(decoded);
        if (json['success'] == true) {
          return json['url']?.toString();
        }
      }
      return null;
    } else {
      _checkAuthError(resp.statusCode);
      throw Exception('Failed to search google image: ${resp.body}');
    }
  }

  static Future<Uint8List?> downloadGoogleImage(
    String treeName,
    String imageType,
  ) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl/external/google-images/download');

    final resp = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({'treeName': treeName, 'imageType': imageType}),
    );

    if (resp.statusCode == 200) {
      final decoded = jsonDecode(resp.body);
      if (decoded is Map) {
        final json = Map<String, dynamic>.from(decoded);
        if (json['success'] == true && json['image'] != null) {
          return base64Decode(json['image'].toString());
        }
      }
      return null;
    } else {
      _checkAuthError(resp.statusCode);
      throw Exception('Failed to download google image: ${resp.body}');
    }
  }

  /// [Added] Get Proxy URL for optimizing image performance (Resizing + WebP)
  static String getProxyImageUrl(String? url, {int? width, int? height}) {
    if (url == null || url.isEmpty) return '';

    // [1] 이미 프록시 처리되었거나 기타 이미지 서버 URL
    if (url.contains('/uploads/proxy')) {
      // ⚠️ 포트가 다르거나 도메인이 다를 경우 현재 baseUrl로 교체 (DB에 옛날 포트로 저장된 경우 대응)
      if (!url.startsWith(baseUrl)) {
        final proxyPathIndex = url.indexOf('/api/uploads/proxy');
        if (proxyPathIndex != -1) {
          url = baseUrl + url.substring(proxyPathIndex + 4); // "/api" 제외 후 baseUrl 결합
        }
      }
      
      if (width != null && !url.contains('&w=')) return '$url&w=$width';
      return url;
    }

    // [2] Supabase Storage 리사이징 활용 (가장 가벼움)
    if (url.contains('supabase.co/storage/v1/object/public/')) {
      if (width != null) {
        final separator = url.contains('?') ? '&' : '?';
        return '$url${separator}width=$width&quality=85';
      }
      return url;
    }

    // [3] 구글 드라이브 또는 외부 URL 프록시 리사이징
    if (url.contains('drive.google.com') ||
        url.contains('googleusercontent.com')) {
      String proxyUrl =
          '$baseUrl/uploads/proxy?url=${Uri.encodeComponent(url)}';
      if (width != null) proxyUrl += '&w=$width';
      if (height != null) proxyUrl += '&h=$height';
      return proxyUrl;
    }

    return url;
  }
}
