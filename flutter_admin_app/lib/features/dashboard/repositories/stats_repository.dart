import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_admin_app/core/repositories/base_repository.dart';

class StatsRepository extends BaseRepository {
  // GET /api/stats
  Future<Map<String, dynamic>> getDashboardStats() async {
    final url = Uri.parse('$baseUrl/stats');
    try {
      final headers = await getHeaders();
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['success'] == true) {
          return jsonResponse['data'];
        }
      }
      checkAuthError(response.statusCode);
    } catch (e) {
      debugPrint('Stats error: $e');
    }
    return {
      'totalTrees': 0,
      'publishedTrees': 0,
      'totalUsers': 0,
      'activeUsers': 0,
    };
  }

  // GET /api/stats/detailed (Detailed Stats)
  Future<Map<String, dynamic>> getDetailedStats() async {
    final url = Uri.parse('$baseUrl/stats/detailed');
    final headers = await getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return jsonResponse['data'];
      }
    }
    checkAuthError(response.statusCode);
    throw Exception('상세 통계 정보를 불러오지 못했습니다: ${response.body}');
  }

  // GET /api/stats/performance/:userId
  Future<Map<String, dynamic>> getUserPerformanceStats(String userId) async {
    final url = Uri.parse('$baseUrl/stats/performance/$userId');
    final headers = await getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return jsonResponse['data'];
      }
    }
    checkAuthError(response.statusCode);
    throw Exception('사용자 개인 통계 정보를 불러오지 못했습니다: ${response.body}');
  }
}
