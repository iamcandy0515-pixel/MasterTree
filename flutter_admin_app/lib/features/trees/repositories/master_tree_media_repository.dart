import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../../core/repositories/base_repository.dart';

class MasterTreeMediaRepository extends BaseRepository {
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
    throw Exception('이미지 업로드 실패: ${response.body}');
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

  Future<Uint8List?> downloadGoogleImage(String treeName, String imageType) async {
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
