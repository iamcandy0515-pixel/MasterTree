import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_admin_app/core/repositories/base_repository.dart';

class SystemSettingsRepository extends BaseRepository {
  // System Restart Commands
  Future<void> restartAdminServer() async {
    final url = Uri.parse('$baseUrl/system/restart/admin');
    final headers = await getHeaders();
    try {
      await http
          .post(url, headers: headers)
          .timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('Admin restart triggered (Connection might be lost): $e');
    }
  }

  Future<void> restartUserServer() async {
    final url = Uri.parse('$baseUrl/system/restart/user');
    final headers = await getHeaders();
    final response = await http.post(url, headers: headers);
    if (response.statusCode != 200) {
      checkAuthError(response.statusCode);
      throw Exception('Failed to restart user server: ${response.body}');
    }
  }

  // GET /api/settings/entry-code
  Future<String> getEntryCode() async {
    final url = Uri.parse('$baseUrl/settings/entry-code');
    final headers = await getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['success'] == true) {
          return jsonResponse['data']['entryCode'] ?? '1234';
        }
      }
      checkAuthError(response.statusCode);
    } catch (e) {
      debugPrint('getEntryCode error: $e');
    }
    return '1234';
  }

  // POST /api/settings/entry-code
  Future<String> updateEntryCode(String newCode) async {
    final url = Uri.parse('$baseUrl/settings/entry-code');
    final headers = await getHeaders();
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
    checkAuthError(response.statusCode);
    throw Exception('입장 코드 업데이트 실패: ${response.body}');
  }

  // GET /api/settings/user-url
  Future<String> getUserAppUrl() async {
    final url = Uri.parse('$baseUrl/settings/user-url');
    final headers = await getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['success'] == true) {
          return jsonResponse['data']['url'] ?? 'http://localhost:8080';
        }
      }
      checkAuthError(response.statusCode);
    } catch (e) {
      debugPrint('getUserAppUrl error: $e');
    }
    return 'http://localhost:8080';
  }

  // POST /api/settings/user-url
  Future<String> updateUserAppUrl(String newUrl) async {
    final url = Uri.parse('$baseUrl/settings/user-url');
    final headers = await getHeaders();
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
    checkAuthError(response.statusCode);
    throw Exception('사용자 URL 업데이트 실패: ${response.body}');
  }

  // GET /api/settings/drive-url
  Future<String> getGoogleDriveFolderUrl() async {
    final url = Uri.parse('$baseUrl/settings/drive-url');
    final headers = await getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['success'] == true) {
          return jsonResponse['data']['url'] ?? '';
        }
      }
      checkAuthError(response.statusCode);
    } catch (e) {
      debugPrint('getGoogleDriveFolderUrl error: $e');
    }
    return '';
  }

  // POST /api/settings/drive-url
  Future<String> updateGoogleDriveFolderUrl(String newUrl) async {
    final url = Uri.parse('$baseUrl/settings/drive-url');
    final headers = await getHeaders();
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
    checkAuthError(response.statusCode);
    throw Exception('구글 드라이브 URL 업데이트 실패: ${response.body}');
  }

  // GET /api/settings/thumbnail-drive-url
  Future<String> getThumbnailDriveUrl() async {
    final url = Uri.parse('$baseUrl/settings/thumbnail-drive-url');
    final headers = await getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['success'] == true) {
          return jsonResponse['data']['url'] ?? '';
        }
      }
      checkAuthError(response.statusCode);
    } catch (e) {
      debugPrint('getThumbnailDriveUrl error: $e');
    }
    return '';
  }

  // POST /api/settings/thumbnail-drive-url
  Future<String> updateThumbnailDriveUrl(String newUrl) async {
    final url = Uri.parse('$baseUrl/settings/thumbnail-drive-url');
    final headers = await getHeaders();
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
    checkAuthError(response.statusCode);
    throw Exception('구글 썸네일 URL 업데이트 실패: ${response.body}');
  }

  // GET /api/settings/exam-drive-url
  Future<String> getExamDriveUrl() async {
    final url = Uri.parse('$baseUrl/settings/exam-drive-url');
    final headers = await getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['success'] == true) {
          return jsonResponse['data']['url'] ?? '';
        }
      }
      checkAuthError(response.statusCode);
    } catch (e) {
      debugPrint('getExamDriveUrl error: $e');
    }
    return '';
  }

  // POST /api/settings/exam-drive-url
  Future<String> updateExamDriveUrl(String newUrl) async {
    final url = Uri.parse('$baseUrl/settings/exam-drive-url');
    final headers = await getHeaders();
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
    checkAuthError(response.statusCode);
    throw Exception('기출문제 폴더 URL 업데이트 실패: ${response.body}');
  }

  // Check URL status (Ping/Head delegated to Backend)
  Future<bool> checkUrlStatus(String urlString) async {
    if (urlString.isEmpty) return false;

    // 1차 클라이언트측 기본 형식 검사 (시간/네트워크 낭비 방지)
    if (!urlString.startsWith('http://') && !urlString.startsWith('https://')) {
      return false;
    }

    try {
      final url = Uri.parse('$baseUrl/settings/validate-url');
      final headers = await getHeaders();

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({'url': urlString}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['success'] == true) {
          return jsonResponse['data']['isValid'] == true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('checkUrlStatus (Backend delegated) error ($urlString): $e');
      return false;
    }
  }
}
