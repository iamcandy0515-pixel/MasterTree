import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_admin_app/core/repositories/base_repository.dart';
import '../models/tree.dart';

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

class MasterTreeRepository extends BaseRepository {
  static String getProxyUrl(String url, {int? width, int? height}) {
    if (url.contains('drive.google.com') || url.startsWith('http')) {
      final baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000/api';
      String proxyUrl =
          '$baseUrl/uploads/proxy?url=${Uri.encodeComponent(url)}';
      if (width != null) proxyUrl += '&w=$width';
      if (height != null) proxyUrl += '&h=$height';
      return proxyUrl;
    }
    return url;
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

    final url = Uri.parse('$baseUrl/trees').replace(queryParameters: queryParams);
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

    final url = Uri.parse('$baseUrl/trees/random').replace(queryParameters: queryParams);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        final List<dynamic> data = jsonResponse['data'];
        return data.map((e) => e.toString()).toList();
      }
    }
    return [];
  }

  // PUT /api/trees/:id (Update)
  Future<Tree> updateTree(int id, CreateTreeRequest request) async {
    final url = Uri.parse('$baseUrl/trees/$id');
    final headers = await getHeaders();

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return Tree.fromJson(jsonResponse['data']);
      }
    }
    checkAuthError(response.statusCode);
    throw Exception('Failed to update tree: ${response.body}');
  }

  // DELETE /api/trees/:id (Delete)
  Future<void> deleteTree(int id) async {
    final url = Uri.parse('$baseUrl/trees/$id');
    final headers = await getHeaders();

    final response = await http.delete(url, headers: headers);

    if (response.statusCode == 200) {
      return;
    }
    checkAuthError(response.statusCode);
    throw Exception('Failed to delete tree: ${response.body}');
  }

  // POST /api/trees (Create)
  Future<Tree> createTree(CreateTreeRequest request) async {
    final url = Uri.parse('$baseUrl/trees');
    final headers = await getHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return Tree.fromJson(jsonResponse['data']);
      }
    }
    checkAuthError(response.statusCode);
    throw Exception('Failed to create tree: ${response.body}');
  }

  // POST /api/uploads/image (Multipart)
  Future<String> uploadImage(XFile imageFile) async {
    final url = Uri.parse('$baseUrl/uploads/image');
    final request = http.MultipartRequest('POST', url);
    final headers = await getHeaders();
    request.headers.addAll(headers);

    final bytes = await imageFile.readAsBytes();
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: imageFile.name),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return jsonResponse['data']['publicUrl'];
      }
    }
    checkAuthError(response.statusCode);
    throw Exception('Failed to upload image: ${response.body}');
  }

  // Export CSV
  Future<String> exportTrees() async {
    final url = Uri.parse('$baseUrl/trees/export');
    final headers = await getHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return utf8.decode(response.bodyBytes);
    }
    checkAuthError(response.statusCode);
    throw Exception('수목 데이터 내보내기 실패: ${response.body}');
  }

  // Import CSV
  Future<Map<String, dynamic>> importTrees(
    List<int> bytes,
    String fileName,
  ) async {
    final url = Uri.parse('$baseUrl/trees/import');
    final request = http.MultipartRequest('POST', url);
    final headers = await getHeaders();
    request.headers.addAll(headers);

    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: fileName),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonResponse['data'];
    }
    checkAuthError(response.statusCode);
    throw Exception('수목 데이터 가져오기 실패: ${response.body}');
  }

  // Search Google Image
  Future<String?> searchGoogleImage(String treeName, String imageType) async {
    final url = Uri.parse('$baseUrl/external/google-images');
    final headers = await getHeaders();

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
    checkAuthError(response.statusCode);
    return null;
  }

  Future<Uint8List?> downloadGoogleImage(
    String treeName,
    String imageType,
  ) async {
    final url = Uri.parse('$baseUrl/external/google-images/download');
    final headers = await getHeaders();

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
    checkAuthError(response.statusCode);
    return null;
  }

  // Create Thumbnail
  Future<String?> generateThumbnail(String treeName, String imageType) async {
    final url = Uri.parse('$baseUrl/external/generate-thumbnail');
    final headers = await getHeaders();

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
    }
    checkAuthError(response.statusCode);
    return null;
  }

  // Get all drive links for a tree
  Future<Map<String, dynamic>> getDriveLinks(String treeName) async {
    final url = Uri.parse('$baseUrl/external/drive-links');
    final headers = await getHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({'treeName': treeName}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return jsonResponse;
      }
    }
    checkAuthError(response.statusCode);
    return {'success': false};
  }

  // Check File Existence in Drive
  Future<bool> checkFileExists(String driveUrl) async {
    final url = Uri.parse('$baseUrl/external/google-drive/exists');
    final headers = await getHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({'url': driveUrl}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonResponse['exists'] == true;
    }
    checkAuthError(response.statusCode);
    return false;
  }
}
