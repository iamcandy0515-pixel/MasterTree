import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_admin_app/features/tree_registration/models/tree_registration_request.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_admin_app/core/api/node_api.dart';

class TreeRegistrationRepository {
  final String _baseUrl;

  TreeRegistrationRepository()
    : _baseUrl = NodeApi.baseUrl;

  // Helper to get headers with Auth Token
  Future<Map<String, String>> _getHeaders() async {
    final session = Supabase.instance.client.auth.currentSession;
    final String token = session?.accessToken ?? '';
    return <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// 신규 수목 등록
  Future<void> registerTree(TreeRegistrationRequest request) async {
    final Uri url = Uri.parse('$_baseUrl/tree-registration');
    final Map<String, String> headers = await _getHeaders();

    final http.Response response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 201) {
      final Map<String, dynamic> error = 
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      throw Exception(error['message']?.toString() ?? '수목 등록에 실패했습니다 (${response.statusCode})');
    }
  }

  /// 이미지 업로드
  Future<String> uploadImage(XFile imageFile) async {
    final Uri url = Uri.parse('$_baseUrl/uploads/image');
    final http.MultipartRequest request = http.MultipartRequest('POST', url);

    // Auth Header
    final session = Supabase.instance.client.auth.currentSession;
    final String token = session?.accessToken ?? '';
    request.headers['Authorization'] = 'Bearer $token';

    // Attach File
    final Uint8List bytes = await imageFile.readAsBytes();
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: imageFile.name),
    );

    final http.StreamedResponse streamedResponse = await request.send();
    final http.Response response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = 
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (jsonResponse['success'] == true) {
        final Map<String, dynamic> data = (jsonResponse['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};
        return data['publicUrl']?.toString() ?? '';
      }
    }
    throw Exception('이미지 업로드에 실패했습니다: ${response.statusCode}');
  }

  /// 이미지 업로드 (Bytes)
  Future<String> uploadImageByBytes(Uint8List bytes, String fileName) async {
    final Uri url = Uri.parse('$_baseUrl/uploads/image');
    final http.MultipartRequest request = http.MultipartRequest('POST', url);

    final session = Supabase.instance.client.auth.currentSession;
    final String token = session?.accessToken ?? '';
    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: fileName),
    );

    final http.StreamedResponse streamedResponse = await request.send();
    final http.Response response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = 
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (jsonResponse['success'] == true) {
        final Map<String, dynamic> data = (jsonResponse['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};
        return data['publicUrl']?.toString() ?? '';
      }
    }
    throw Exception('이미지 업로드에 실패했습니다: ${response.statusCode}');
  }

  /// 구글 드라이브 업로드 (주로 붙여넣기 이미지)
  Future<String> uploadToGoogleDrive(
    XFile imageFile, {
    String? fileName,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/uploads/google-drive');
    final http.MultipartRequest request = http.MultipartRequest('POST', url);

    final session = Supabase.instance.client.auth.currentSession;
    final String token = session?.accessToken ?? '';
    request.headers['Authorization'] = 'Bearer $token';

    if (fileName != null) request.fields['fileName'] = fileName;

    final Uint8List bytes = await imageFile.readAsBytes();
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: imageFile.name),
    );

    final http.StreamedResponse streamedResponse = await request.send();
    final http.Response response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = 
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (jsonResponse['success'] == true) {
        final Map<String, dynamic> data = (jsonResponse['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};
        return data['url']?.toString() ?? '';
      }
    }
    throw Exception('구글 드라이브 업로드 실패: ${response.statusCode}');
  }

  /// 구글 이미지 검색 및 스토리지 연결 (B 방식)
  Future<String?> searchAndAttachGoogleImage(
    String treeName,
    String imageType,
  ) async {
    final Uri url = Uri.parse('$_baseUrl/external/google-images/attach');
    final Map<String, String> headers = await _getHeaders();

    final http.Response response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(<String, dynamic>{'treeName': treeName, 'imageType': imageType}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = 
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (jsonResponse['success'] == true) {
        return jsonResponse['url']?.toString();
      }
    }
    return null;
  }
}
