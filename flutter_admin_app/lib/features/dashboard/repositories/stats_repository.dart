import 'dart:convert';
import 'package:flutter/foundation.dart';
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
        final dynamic decoded = json.decode(response.body);
        if (decoded is! Map) return _defaultStats();
        
        final Map<String, dynamic> jsonResponse = Map<String, dynamic>.from(decoded);
        if (jsonResponse['success'] == true) {
          final dynamic rawData = jsonResponse['data'];
          if (rawData is! Map) return _defaultStats();
          return Map<String, dynamic>.from(rawData as Map);
        }
      }
      checkAuthError(response.statusCode);
    } catch (e) {
      debugPrint('❌ Stats error: $e');
    }
    return _defaultStats();
  }

  Map<String, dynamic> _defaultStats() {
    return <String, dynamic>{
      'totalTrees': 0,
      'publishedTrees': 0,
      'totalUsers': 0,
      'activeUsers': 0,
      'totalQuizzes': 0,
      'totalSimilarGroups': 0,
    };
  }

  // GET /api/stats/detailed
  Future<Map<String, dynamic>> getDetailedStats() async {
    final url = Uri.parse('$baseUrl/stats/detailed');
    final headers = await getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final dynamic decoded = json.decode(response.body);
      if (decoded is Map) {
        final Map<String, dynamic> jsonResponse = Map<String, dynamic>.from(decoded);
        if (jsonResponse['success'] == true) {
          final dynamic rawData = jsonResponse['data'];
          if (rawData is Map) return Map<String, dynamic>.from(rawData as Map);
        }
      }
    }
    checkAuthError(response.statusCode);
    throw Exception('상세 통계 정보를 불러오지 못했습니다: ${response.statusCode}');
  }

  // GET /api/stats/performance/:userId
  Future<Map<String, dynamic>> getUserPerformanceStats(String userId) async {
    final url = Uri.parse('$baseUrl/stats/performance/$userId');
    final headers = await getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final dynamic decoded = json.decode(response.body);
      if (decoded is Map) {
        final Map<String, dynamic> jsonResponse = Map<String, dynamic>.from(decoded);
        if (jsonResponse['success'] == true) {
          final dynamic rawData = jsonResponse['data'];
          if (rawData is Map) return Map<String, dynamic>.from(rawData as Map);
        }
      }
    }
    checkAuthError(response.statusCode);
    throw Exception('사용자 개인 통계 정보를 불러오지 못했습니다: ${response.statusCode}');
  }
}
