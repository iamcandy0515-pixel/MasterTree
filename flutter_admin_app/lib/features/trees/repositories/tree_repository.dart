import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tree.dart';
import '../models/tree_group.dart';

class PaginatedTrees {
  final List<Tree> trees;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginatedTrees({
    required this.trees,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });
}

class TreeRepository {
  final String _baseUrl;

  static String getProxyUrl(String url) {
    if (url.contains('drive.google.com')) {
      final baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000/api';
      return '$baseUrl/uploads/proxy?url=${Uri.encodeComponent(url)}';
    }
    return url;
  }

  TreeRepository()
    : _baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000/api';

  // Helper to get headers with Auth Token
  Future<Map<String, String>> _getHeaders() async {
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // GET /api/trees with Pagination
  Future<PaginatedTrees> getTrees({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
      if (category != null && category != '전체') 'category': category,
    };

    final url = Uri.parse(
      '$_baseUrl/trees',
    ).replace(queryParameters: queryParams);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        final List<dynamic> data = jsonResponse['data'];
        final meta = jsonResponse['meta'];

        return PaginatedTrees(
          trees: data.map((e) => Tree.fromJson(e)).toList(),
          total: meta['total'] ?? 0,
          page: meta['page'] ?? 1,
          limit: meta['limit'] ?? 20,
          totalPages: meta['totalPages'] ?? 1,
        );
      }
    }
    throw Exception('Failed to load trees: ${response.body}');
  }

  // GET /api/trees/random
  Future<List<String>> getRandomTrees({
    required int count,
    String? category,
    String? excludeName,
  }) async {
    final queryParams = {
      'count': count.toString(),
      if (category != null) 'category': category,
      if (excludeName != null) 'excludeName': excludeName,
    };

    final url = Uri.parse(
      '$_baseUrl/trees/random',
    ).replace(queryParameters: queryParams);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        final List<dynamic> data = jsonResponse['data'];
        return data.map((e) => e.toString()).toList();
      }
    }
    // Fallback or empty list on error for seamless UX?
    // Better to return empty list or throw specific error.
    return [];
  }

  // Legacy support if needed, or remove
  // Future<List<Tree>> getAllTrees() ...

  // PUT /api/trees/:id (Update)
  Future<Tree> updateTree(int id, CreateTreeRequest request) async {
    final url = Uri.parse('$_baseUrl/trees/$id');
    final headers = await _getHeaders();

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(request.toJson()), // Reusing create request structure
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return Tree.fromJson(jsonResponse['data']);
      }
    }
    throw Exception('Failed to update tree: ${response.body}');
  }

  // DELETE /api/trees/:id (Delete)
  Future<void> deleteTree(int id) async {
    final url = Uri.parse('$_baseUrl/trees/$id');
    final headers = await _getHeaders();

    final response = await http.delete(url, headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return; // Success
      }
    }
    throw Exception('Failed to delete tree: ${response.body}');
  }

  // POST /api/trees (Create)
  Future<Tree> createTree(CreateTreeRequest request) async {
    final url = Uri.parse('$_baseUrl/trees');
    final headers = await _getHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return Tree.fromJson(
          jsonResponse['data'],
        ); // The backend returns the created tree (though typically without ID if not refetched, but DTO might have it)
        // Actually Service returns { ...treeData, tree_images: dto.images } which has ID.
      }
    }
    throw Exception('Failed to create tree: ${response.body}');
  }

  // POST /api/uploads/image (Multipart)
  Future<String> uploadImage(XFile imageFile) async {
    final url = Uri.parse('$_baseUrl/uploads/image');
    final request = http.MultipartRequest('POST', url);

    // Auth Header for Upload
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken ?? '';
    request.headers['Authorization'] = 'Bearer $token';

    // Attach File (Web compatible)
    final bytes = await imageFile.readAsBytes();
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: imageFile.name),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        // Return publicUrl
        return jsonResponse['data']['publicUrl'];
      }
    }
    throw Exception('Failed to upload image: ${response.body}');
  }

  // Export CSV
  Future<String> exportTrees() async {
    final url = Uri.parse('$_baseUrl/trees/export');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return utf8.decode(response.bodyBytes);
    }
    throw Exception('수목 데이터 내보내기 실패: ${response.body}');
  }

  // Import CSV
  Future<Map<String, dynamic>> importTrees(
    List<int> bytes,
    String fileName,
  ) async {
    final url = Uri.parse('$_baseUrl/trees/import');
    final request = http.MultipartRequest('POST', url);
    final session = Supabase.instance.client.auth.currentSession;
    request.headers['Authorization'] = 'Bearer ${session?.accessToken}';

    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: fileName),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonResponse['data'];
    }
    throw Exception('수목 데이터 가져오기 실패: ${response.body}');
  }

  // GET /api/tree-groups (Lookalike Groups)
  Future<Map<String, dynamic>> getTreeGroups({
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = {'page': page.toString(), 'limit': limit.toString()};
    final url = Uri.parse(
      '$_baseUrl/tree-groups',
    ).replace(queryParameters: queryParams);
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return {
          'groups': (jsonResponse['data'] as List)
              .map((e) => TreeGroup.fromJson(e))
              .toList(),
          'meta': jsonResponse['meta'],
        };
      }
    }
    throw Exception('유사종 데이터를 불러오지 못했습니다: ${response.body}');
  }

  // GET /api/tree-groups/:id
  Future<TreeGroup> getTreeGroupById(String id) async {
    final url = Uri.parse('$_baseUrl/tree-groups/$id');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return TreeGroup.fromJson(jsonResponse['data']);
      }
    }
    throw Exception('유사종 그룹 상세 알 정보를 불러오지 못했습니다: ${response.body}');
  }

  // Search Google Image
  Future<String?> searchGoogleImage(String treeName, String imageType) async {
    final url = Uri.parse('$_baseUrl/external/google-images');
    final headers = await _getHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({'treeName': treeName, 'imageType': imageType}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return jsonResponse['url'];
      }
      return null;
    }
    // Fail silently or throw? For now silently return null if not found
    return null;
  }

  Future<Uint8List?> downloadGoogleImage(
    String treeName,
    String imageType,
  ) async {
    final url = Uri.parse('$_baseUrl/external/google-images/download');
    final headers = await _getHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({'treeName': treeName, 'imageType': imageType}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true && jsonResponse['image'] != null) {
        return base64Decode(jsonResponse['image']);
      }
    }
    return null;
  }

  // GET /api/stats
  Future<Map<String, dynamic>> getDashboardStats() async {
    final url = Uri.parse('$_baseUrl/stats');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['success'] == true) {
          return jsonResponse['data'];
        }
      }
    } catch (e) {
      print('Stats error: $e');
    }
    return {
      'totalTrees': 0,
      'publishedTrees': 0,
      'totalUsers': 0,
      'activeUsers': 0,
    };
  }

  // POST /api/tree-groups
  Future<TreeGroup> createTreeGroup(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/tree-groups');
    final headers = await _getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        // The backend returns the group object without members detailed structure sometimes if not joined.
        // But TreeGroup.fromJson handles it safely (empty list if null).
        // Ideally backend should return full structure.
        return TreeGroup.fromJson(jsonResponse['data']);
      }
    }
    throw Exception('Failed to create tree group: ${response.body}');
  }

  // PUT /api/tree-groups/:id
  Future<TreeGroup> updateTreeGroup(
    String id,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$_baseUrl/tree-groups/$id');
    final headers = await _getHeaders();
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        // Since the backend logic returns {id, ...data}, we might need to be careful if it doesn't return full object.
        // But updating the list locally or refetching is typical.
        return TreeGroup.fromJson(jsonResponse['data']);
      }
    }
    throw Exception('Failed to update tree group: ${response.body}');
  }

  // DELETE /api/tree-groups/:id
  Future<void> deleteTreeGroup(String id) async {
    final url = Uri.parse('$_baseUrl/tree-groups/$id');
    final headers = await _getHeaders();
    final response = await http.delete(url, headers: headers);

    if (response.statusCode == 200) {
      return;
    }
    throw Exception('Failed to delete tree group: ${response.body}');
  }

  // System Restart Commands
  Future<void> restartAdminServer() async {
    final url = Uri.parse('$_baseUrl/system/restart/admin');
    final headers = await _getHeaders();
    try {
      // Intentionally ignore response or handle error gracefully
      // The server will die, so we might get a network error or a success response depending on timing.
      await http
          .post(url, headers: headers)
          .timeout(const Duration(seconds: 2));
    } catch (e) {
      // Expected since server restarts
      print('Admin restart triggered: $e');
    }
  }

  Future<void> restartUserServer() async {
    final url = Uri.parse('$_baseUrl/system/restart/user');
    final headers = await _getHeaders();
    final response = await http.post(url, headers: headers);
    if (response.statusCode != 200) {
      throw Exception('Failed to restart user server: ${response.body}');
    }
  }

  // GET /api/stats/detailed (Detailed Stats)
  Future<Map<String, dynamic>> getDetailedStats() async {
    final url = Uri.parse('$_baseUrl/stats/detailed');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return jsonResponse['data'];
      }
    }
    throw Exception('상세 통계 정보를 불러오지 못했습니다: ${response.body}');
  }

  // GET /api/stats/performance/:userId
  Future<Map<String, dynamic>> getUserPerformanceStats(String userId) async {
    final url = Uri.parse('$_baseUrl/stats/performance/$userId');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return jsonResponse['data'];
      }
    }
    throw Exception('사용자 개인 통계 정보를 불러오지 못했습니다: ${response.body}');
  }

  // GET /api/settings/entry-code
  Future<String> getEntryCode() async {
    final url = Uri.parse('$_baseUrl/settings/entry-code');
    final headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        // Handle table missing fallback handled in backend, but double check
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['success'] == true) {
          return jsonResponse['data']['entryCode'] ?? '1234';
        }
      }
    } catch (e) {
      // Ignore
    }
    return '1234';
  }

  // POST /api/settings/entry-code
  Future<String> updateEntryCode(String newCode) async {
    final url = Uri.parse('$_baseUrl/settings/entry-code');
    final headers = await _getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({'entryCode': newCode}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return jsonResponse['data']['entryCode'];
      }
    }
    throw Exception('입장 코드 업데이트 실패: ${response.body}');
  }

  // GET /api/settings/user-url
  Future<String> getUserAppUrl() async {
    final url = Uri.parse('$_baseUrl/settings/user-url');
    final headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['success'] == true) {
          return jsonResponse['data']['url'] ?? 'http://localhost:8080';
        }
      }
    } catch (e) {
      // Ignore
    }
    return 'http://localhost:8080';
  }

  // POST /api/settings/user-url
  Future<String> updateUserAppUrl(String newUrl) async {
    final url = Uri.parse('$_baseUrl/settings/user-url');
    final headers = await _getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({'url': newUrl}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return jsonResponse['data']['url'];
      }
    }
    throw Exception('사용자 URL 업데이트 실패: ${response.body}');
  }

  // GET /api/settings/drive-url
  Future<String> getGoogleDriveFolderUrl() async {
    final url = Uri.parse('$_baseUrl/settings/drive-url');
    final headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['success'] == true) {
          return jsonResponse['data']['url'] ?? '';
        }
      }
    } catch (e) {
      // Ignore
    }
    return '';
  }

  // POST /api/settings/drive-url
  Future<String> updateGoogleDriveFolderUrl(String newUrl) async {
    final url = Uri.parse('$_baseUrl/settings/drive-url');
    final headers = await _getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({'url': newUrl}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return jsonResponse['data']['url'];
      }
    }
    throw Exception('구글 드라이브 URL 업데이트 실패: ${response.body}');
  }

  // GET /api/settings/thumbnail-drive-url
  Future<String> getThumbnailDriveUrl() async {
    final url = Uri.parse('$_baseUrl/settings/thumbnail-drive-url');
    final headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['success'] == true) {
          return jsonResponse['data']['url'] ?? '';
        }
      }
    } catch (e) {
      // Ignore
    }
    return '';
  }

  // POST /api/settings/thumbnail-drive-url
  Future<String> updateThumbnailDriveUrl(String newUrl) async {
    final url = Uri.parse('$_baseUrl/settings/thumbnail-drive-url');
    final headers = await _getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({'url': newUrl}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return jsonResponse['data']['url'];
      }
    }
    throw Exception('구글 썸네일 URL 업데이트 실패: ${response.body}');
  }

  // GET /api/settings/exam-drive-url
  Future<String> getExamDriveUrl() async {
    final url = Uri.parse('$_baseUrl/settings/exam-drive-url');
    final headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['success'] == true) {
          return jsonResponse['data']['url'] ?? '';
        }
      }
    } catch (e) {
      // Ignore
    }
    return '';
  }

  // POST /api/settings/exam-drive-url
  Future<String> updateExamDriveUrl(String newUrl) async {
    final url = Uri.parse('$_baseUrl/settings/exam-drive-url');
    final headers = await _getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({'url': newUrl}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return jsonResponse['data']['url'];
      }
    }
    throw Exception('기출문제 폴더 URL 업데이트 실패: ${response.body}');
  }
}
