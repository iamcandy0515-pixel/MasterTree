import 'package:flutter/foundation.dart';
import '../constants.dart';
import 'base_api_service.dart';

class GroupService {
  static Future<List<Map<String, dynamic>>> getTreeGroups() async {
    final url = Uri.parse('${AppConstants.apiUrl}/tree-groups');
    try {
      final Map<String, dynamic> jsonResponse = await BaseApiService.get(url);
      if (jsonResponse['success'] == true) {
        final dynamic data = jsonResponse['data'];
        if (data is Iterable) {
          return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
        return <Map<String, dynamic>>[];
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
        final dynamic data = jsonResponse['data'];
        if (data is Map) {
          return Map<String, dynamic>.from(data);
        }
        return <String, dynamic>{};
      }
      throw Exception('Failed to load group: ${jsonResponse['message']}');
    } catch (e) {
      debugPrint('GroupService.getTreeGroup Error: $e');
      rethrow;
    }
  }
}
