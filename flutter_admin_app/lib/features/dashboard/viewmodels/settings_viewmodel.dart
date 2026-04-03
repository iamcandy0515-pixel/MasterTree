import 'package:flutter/material.dart';
import 'package:flutter_admin_app/features/dashboard/repositories/system_settings_repository.dart';

class SettingsViewModel extends ChangeNotifier {
  final SystemSettingsRepository _repository = SystemSettingsRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isInitialLoading = true;
  bool get isInitialLoading => _isInitialLoading;

  String? _error;
  String? get error => _error;

  String _entryCode = "1234";
  String get entryCode => _entryCode;

  String _userAppUrl = "https://mastertree-user-app.vercel.app";
  String get userAppUrl => _userAppUrl;

  String _userNotification = "";
  String get userNotification => _userNotification;

  String _googleDriveUrl = "";
  String get googleDriveUrl => _googleDriveUrl;

  String _thumbnailDriveUrl = "";
  String get thumbnailDriveUrl => _thumbnailDriveUrl;

  String _examDriveUrl = "";
  String get examDriveUrl => _examDriveUrl;

  // URL Status Maps (null: not checked, true: OK, false: Error)
  final Map<String, bool?> _urlStatuses = {};
  bool? getUrlStatus(String key) => _urlStatuses[key];

  final Map<String, bool> _checkLoading = {};
  bool isCheckLoading(String key) => _checkLoading[key] ?? false;

  Future<void> loadSettings() async {
    _isLoading = true;
    _isInitialLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.getEntryCode(),
        _repository.getUserAppUrl(),
        _repository.getUserNotification(), // 사용자 알림 추가
        _repository.getGoogleDriveFolderUrl(),
        _repository.getThumbnailDriveUrl(),
        _repository.getExamDriveUrl(),
      ]);
      _entryCode = results[0];
      _userAppUrl = results[1];
      _userNotification = results[2];
      _googleDriveUrl = results[3];
      _thumbnailDriveUrl = results[4];
      _examDriveUrl = results[5];
      _error = null;

      checkAllUrls();
    } catch (e) {
      _error = "설정 정보를 불러오는데 실패했습니다.";
    } finally {
      _isLoading = false;
      _isInitialLoading = false;
      notifyListeners();
    }
  }

  void checkAllUrls() {
    checkUrl('userApp', _userAppUrl);
    checkUrl('googleDrive', _googleDriveUrl);
    checkUrl('thumbnailDrive', _thumbnailDriveUrl);
    checkUrl('examDrive', _examDriveUrl);
  }

  Future<void> checkUrl(String key, String url) async {
    if (url.isEmpty) return;
    _checkLoading[key] = true;
    notifyListeners();

    final isOk = await _repository.checkUrlStatus(url);
    _urlStatuses[key] = isOk;
    _checkLoading[key] = false;
    notifyListeners();
  }

  Future<void> updateEntryCode(String newCode) async {
    _isLoading = true;
    notifyListeners();
    try {
      _entryCode = await _repository.updateEntryCode(newCode);
      _error = null;
    } catch (e) {
      _error = "입장 코드 수정에 실패했습니다: $e";
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserAppUrl(String newUrl) async {
    _isLoading = true;
    notifyListeners();
    try {
      _userAppUrl = await _repository.updateUserAppUrl(newUrl);
      _error = null;
      checkUrl('userApp', _userAppUrl);
    } catch (e) {
      _error = "URL 수정에 실패했습니다: $e";
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserNotification(String message) async {
    _isLoading = true;
    notifyListeners();
    try {
      _userNotification = await _repository.updateUserNotification(message);
      _error = null;
    } catch (e) {
      _error = "알림 정보 수정에 실패했습니다: $e";
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateGoogleDriveFolderUrl(String newUrl) async {
    _isLoading = true;
    notifyListeners();
    try {
      _googleDriveUrl = await _repository.updateGoogleDriveFolderUrl(newUrl);
      _error = null;
      checkUrl('googleDrive', _googleDriveUrl);
    } catch (e) {
      _error = "구글 드라이브 URL 수정에 실패했습니다: $e";
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateThumbnailDriveUrl(String newUrl) async {
    _isLoading = true;
    notifyListeners();
    try {
      _thumbnailDriveUrl = await _repository.updateThumbnailDriveUrl(newUrl);
      _error = null;
      checkUrl('thumbnailDrive', _thumbnailDriveUrl);
    } catch (e) {
      _error = "구글 썸네일 URL 수정에 실패했습니다: $e";
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateExamDriveUrl(String newUrl) async {
    _isLoading = true;
    notifyListeners();
    try {
      _examDriveUrl = await _repository.updateExamDriveUrl(newUrl);
      _error = null;
      checkUrl('examDrive', _examDriveUrl);
    } catch (e) {
      _error = "기출문제 URL 수정에 실패했습니다: $e";
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Support for Server Control Card Actions
  Future<void> restartAdminServer() async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulate action
      _error = null;
    } catch (e) {
      _error = "관리자 서버 재시작 요청 실패";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> restartUserServer() async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulate action
      _error = null;
    } catch (e) {
      _error = "사용자 서버 재시작 요청 실패";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
