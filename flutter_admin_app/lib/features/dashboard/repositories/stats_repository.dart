import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_admin_app/core/repositories/base_repository.dart';

class StatsRepository extends BaseRepository {
  // GET /api/stats
  Future<Map<String, dynamic>> getDashboardStats() async {
    final Uri url = Uri.parse('$baseUrl/stats');
    try {
      final Map<String, String> headers = await getHeaders();
      final http.Response response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = 
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        if (jsonResponse['success'] == true) {
          return (jsonResponse['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};
        }
      }
      checkAuthError(response.statusCode);
    } catch (e) {
      debugPrint('Stats error: $e');
    }
    return <String, dynamic>{
      'totalTrees': 0,
      'publishedTrees': 0,
      'totalUsers': 0,
      'activeUsers': 0,
    };
  }

  // GET /api/stats/detailed (Detailed Stats)
  Future<Map<String, dynamic>> getDetailedStats() async {
    final Uri url = Uri.parse('$baseUrl/stats/detailed');
    final Map<String, String> headers = await getHeaders();
    final http.Response response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = 
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (jsonResponse['success'] == true) {
        return (jsonResponse['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      }
    }
    checkAuthError(response.statusCode);
    throw Exception('상세 통계 정보를 불러오지 못했습니다: ${response.statusCode}');
  }

  // GET /api/stats/performance/:userId
  Future<Map<String, dynamic>> getUserPerformanceStats(String userId) async {
    final Uri url = Uri.parse('$baseUrl/stats/performance/$userId');
    final Map<String, String> headers = await getHeaders();
    final http.Response response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = 
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (jsonResponse['success'] == true) {
        return (jsonResponse['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      }
    }
    checkAuthError(response.statusCode);
    throw Exception('사용자 개인 통계 정보를 불러오지 못했습니다: ${response.statusCode}');
  }

  // GET /api/stats/categories/:userId
  Future<List<Map<String, dynamic>>> getTreeCategoryStats(String userId) async {
    final Uri url = Uri.parse('$baseUrl/stats/categories/$userId');
    final Map<String, String> headers = await getHeaders();
    final http.Response response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (jsonResponse['success'] == true) {
        return List<Map<String, dynamic>>.from(
            (jsonResponse['data'] as Iterable<dynamic>?) ?? <dynamic>[]);
      }
    }
    checkAuthError(response.statusCode);
    throw Exception('나무 카테고리 통계를 불러오지 못했습니다: ${response.statusCode}');
  }

  // GET /api/stats/exams/:userId
  Future<List<Map<String, dynamic>>> getExamSessionStats(String userId) async {
    final Uri url = Uri.parse('$baseUrl/stats/exams/$userId');
    final Map<String, String> headers = await getHeaders();
    final http.Response response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (jsonResponse['success'] == true) {
        return List<Map<String, dynamic>>.from(
            (jsonResponse['data'] as Iterable<dynamic>?) ?? <dynamic>[]);
      }
    }
    checkAuthError(response.statusCode);
    throw Exception('기출문제 세션 통계를 불러오지 못했습니다: ${response.statusCode}');
  }
}
