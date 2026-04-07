import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_admin_app/core/repositories/base_repository.dart';
import '../models/tree_group.dart';

class TreeGroupRepository extends BaseRepository {
  // GET /api/tree-groups (Lookalike Groups)
  Future<Map<String, dynamic>> getTreeGroups({
    int page = 1,
    int limit = 10,
    String? query,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (query != null && query.isNotEmpty) 'query': query,
    };
    final url = Uri.parse('$baseUrl/tree-groups').replace(queryParameters: queryParams);
    final headers = await getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (jsonResponse['success'] == true) {
        return <String, dynamic>{
          'groups': (jsonResponse['data'] as List<dynamic>? ?? <dynamic>[])
              .map((dynamic e) => TreeGroup.fromJson(e as Map<String, dynamic>))
              .toList(),
          'meta': jsonResponse['meta'],
        };
      }
    }
    checkAuthError(response.statusCode);
    throw Exception('유사종 데이터를 불러오지 못했습니다: ${response.body}');
  }

  // GET /api/tree-groups/:id
  Future<TreeGroup> getTreeGroupById(String id) async {
    final url = Uri.parse('$baseUrl/tree-groups/$id');
    final headers = await getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (jsonResponse['success'] == true) {
        return TreeGroup.fromJson(jsonResponse['data'] as Map<String, dynamic>);
      }
    }
    checkAuthError(response.statusCode);
    throw Exception('유사종 그룹 정보를 불러오지 못했습니다: ${response.body}');
  }

  // POST /api/tree-groups
  Future<TreeGroup> createTreeGroup(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/tree-groups');
    final headers = await getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (jsonResponse['success'] == true) {
        return TreeGroup.fromJson(jsonResponse['data'] as Map<String, dynamic>);
      }
    }
    checkAuthError(response.statusCode);
    throw Exception('Failed to create tree group: ${response.body}');
  }

  // PUT /api/tree-groups/:id
  Future<TreeGroup> updateTreeGroup(
    String id,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl/tree-groups/$id');
    final headers = await getHeaders();
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (jsonResponse['success'] == true) {
        return TreeGroup.fromJson(jsonResponse['data'] as Map<String, dynamic>);
      }
    }
    checkAuthError(response.statusCode);
    throw Exception('Failed to update tree group: ${response.body}');
  }

  // DELETE /api/tree-groups/:id
  Future<void> deleteTreeGroup(String id) async {
    final url = Uri.parse('$baseUrl/tree-groups/$id');
    final headers = await getHeaders();
    final response = await http.delete(url, headers: headers);

    if (response.statusCode == 200) {
      return;
    }
    checkAuthError(response.statusCode);
    throw Exception('Failed to delete tree group: ${response.body}');
  }
}
