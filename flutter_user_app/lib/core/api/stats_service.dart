import 'package:flutter/foundation.dart';
import '../constants.dart';
import 'base_api_service.dart';

class StatsService {
  static Future<Map<String, dynamic>> getUserStats() async {
    final url = Uri.parse('${AppConstants.apiUrl}/stats/user');
    try {
      final Map<String, dynamic> jsonResponse = await BaseApiService.get(url);
      if (jsonResponse['success'] == true) {
        return Map<String, dynamic>.from((jsonResponse['data'] as Map<dynamic, dynamic>?) ?? <String, dynamic>{});
      }
      throw Exception('Failed to load stats: ${jsonResponse['message']}');
    } catch (e) {
      debugPrint('StatsService.getUserStats Error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getUserPerformanceStats() async {
    final url = Uri.parse('${AppConstants.apiUrl}/stats/performance');
    try {
      final Map<String, dynamic> jsonResponse = await BaseApiService.get(url);
      if (jsonResponse['success'] == true) {
        return Map<String, dynamic>.from((jsonResponse['data'] as Map<dynamic, dynamic>?) ?? <String, dynamic>{});
      }
      throw Exception('상태 코드: ${jsonResponse['message']}');
    } catch (e) {
      debugPrint('StatsService.getUserPerformanceStats Error: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getTreeCategoryStats() async {
    final url = Uri.parse('${AppConstants.apiUrl}/stats/categories');
    try {
      final Map<String, dynamic> jsonResponse = await BaseApiService.get(url);
      if (jsonResponse['success'] == true) {
        return List<Map<String, dynamic>>.from((jsonResponse['data'] as Iterable<dynamic>?) ?? <dynamic>[]);
      }
      throw Exception('나무 통계 로드 실패: ${jsonResponse['message']}');
    } catch (e) {
      debugPrint('StatsService.getTreeCategoryStats Error: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getExamSessionStats() async {
    final url = Uri.parse('${AppConstants.apiUrl}/stats/exams');
    try {
      final Map<String, dynamic> jsonResponse = await BaseApiService.get(url);
      if (jsonResponse['success'] == true) {
        return List<Map<String, dynamic>>.from((jsonResponse['data'] as Iterable<dynamic>?) ?? <dynamic>[]);
      }
      throw Exception('기출 통계 로드 실패: ${jsonResponse['message']}');
    } catch (e) {
      debugPrint('StatsService.getExamSessionStats Error: $e');
      rethrow;
    }
  }
}

class GroupService {
  static Future<List<Map<String, dynamic>>> getTreeGroups() async {
    final url = Uri.parse('${AppConstants.apiUrl}/tree-groups');
    try {
      final Map<String, dynamic> jsonResponse = await BaseApiService.get(url);
      if (jsonResponse['success'] == true) {
        return List<Map<String, dynamic>>.from((jsonResponse['data'] as Iterable<dynamic>?) ?? <dynamic>[]);
      }
      throw Exception('Failed to load groups: ${jsonResponse['message']}');
    } catch (e) {
      debugPrint('GroupService.getTreeGroups Error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getTreeGroup(String id) async {
    final url = Uri.parse('${AppConstants.apiUrl}/tree-groups/$id');
    try {
      final Map<String, dynamic> jsonResponse = await BaseApiService.get(url);
      if (jsonResponse['success'] == true) {
        return Map<String, dynamic>.from((jsonResponse['data'] as Map<dynamic, dynamic>?) ?? <String, dynamic>{});
      }
      throw Exception('Failed to load group: ${jsonResponse['message']}');
    } catch (e) {
      debugPrint('GroupService.getTreeGroup Error: $e');
      rethrow;
    }
  }
}
