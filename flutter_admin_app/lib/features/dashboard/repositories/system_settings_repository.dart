import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_admin_app/core/repositories/base_repository.dart';

class SystemSettingsRepository extends BaseRepository {
  // Generic Fetch Helper (Rule 3-1: DRY)
  Future<T> _fetchSetting<T>(String endpoint, {required T defaultValue, String dataKey = 'url'}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['success'] == true) {
          return (jsonResponse['data'][dataKey] as T?) ?? defaultValue;
        }
      }
      checkAuthError(response.statusCode);
    } catch (e) {
      debugPrint('Fetch error at $endpoint: $e');
    }
    return defaultValue;
  }

  // Generic Update Helper (Rule 3-1: DRY)
  Future<T> _postSetting<T>(String endpoint, Map<String, dynamic> body, {String dataKey = 'url', String errorPrefix = '업데이트 실패'}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await getHeaders();
    final response = await http.post(url, headers: headers, body: jsonEncode(body));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success'] == true) {
        return (jsonResponse['data'][dataKey] as T);
      }
    }
    checkAuthError(response.statusCode);
    throw Exception('$errorPrefix: ${response.body}');
  }

  // Settings Management
  Future<String> getEntryCode() => _fetchSetting('/settings/entry-code', defaultValue: '1234', dataKey: 'entryCode');
  Future<String> updateEntryCode(String newCode) => _postSetting('/settings/entry-code', {'entryCode': newCode}, dataKey: 'entryCode', errorPrefix: '입장 코드 업데이트 실패');

  Future<String> getUserAppUrl() => _fetchSetting('/settings/user-url', defaultValue: 'https://mastertree-user-app.vercel.app');
  Future<String> updateUserAppUrl(String newUrl) => _postSetting('/settings/user-url', {'url': newUrl}, errorPrefix: '사용자 URL 업데이트 실패');

  // New: User Notification Management
  Future<String> getUserNotification() => _fetchSetting('/settings/notification', defaultValue: '', dataKey: 'value');
  Future<String> updateUserNotification(String message) => _postSetting('/settings/notification', {'notification': message}, dataKey: 'value', errorPrefix: '알림 정보 업데이트 실패');

  Future<String> getGoogleDriveFolderUrl() => _fetchSetting('/settings/drive-url', defaultValue: '');
  Future<String> updateGoogleDriveFolderUrl(String newUrl) => _postSetting('/settings/drive-url', {'url': newUrl}, errorPrefix: '구글 드라이브 URL 업데이트 실패');

  Future<String> getThumbnailDriveUrl() => _fetchSetting('/settings/thumbnail-drive-url', defaultValue: '');
  Future<String> updateThumbnailDriveUrl(String newUrl) => _postSetting('/settings/thumbnail-drive-url', {'url': newUrl}, errorPrefix: '구글 썸네일 URL 업데이트 실패');

  Future<String> getExamDriveUrl() => _fetchSetting('/settings/exam-drive-url', defaultValue: '');
  Future<String> updateExamDriveUrl(String newUrl) => _postSetting('/settings/exam-drive-url', {'url': newUrl}, errorPrefix: '기출문제 폴더 URL 업데이트 실패');

  // URL Validation (Specific Logic)
  Future<bool> checkUrlStatus(String urlString) async {
    if (urlString.isEmpty || (!urlString.startsWith('http://') && !urlString.startsWith('https://'))) return false;

    try {
      final url = Uri.parse('$baseUrl/settings/validate-url');
      final headers = await getHeaders();
      final response = await http.post(url, headers: headers, body: jsonEncode({'url': urlString}));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['success'] == true) {
          return jsonResponse['data']['isValid'] == true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('checkUrlStatus fatal error ($urlString): $e');
      return false;
    }
  }
}
