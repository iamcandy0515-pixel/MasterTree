import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_admin_app/features/tree_registration/models/tree_registration_request.dart';
import 'package:image_picker/image_picker.dart';

class TreeRegistrationRepository {
  final String _baseUrl;

  TreeRegistrationRepository()
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

  /// 신규 수목 등록
  Future<void> registerTree(TreeRegistrationRequest request) async {
    final url = Uri.parse('$_baseUrl/tree-registration');
    final headers = await _getHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 201) {
      final error = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(error['message'] ?? '수목 등록에 실패했습니다.');
    }
  }

  /// 이미지 업로드
  Future<String> uploadImage(XFile imageFile) async {
    final url = Uri.parse('$_baseUrl/uploads/image');
    final request = http.MultipartRequest('POST', url);

    // Auth Header
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken ?? '';
    request.headers['Authorization'] = 'Bearer $token';

    // Attach File
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
    throw Exception('이미지 업로드에 실패했습니다: ${response.body}');
  }
}
