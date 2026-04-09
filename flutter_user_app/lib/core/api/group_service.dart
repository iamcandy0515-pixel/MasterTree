import 'package:flutter/foundation.dart';
import '../constants.dart';
import 'base_api_service.dart';

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
