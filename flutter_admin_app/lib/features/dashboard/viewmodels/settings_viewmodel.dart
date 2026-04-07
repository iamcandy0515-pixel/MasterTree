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

  String _googleDriveUrl = "";
  String get googleDriveUrl => _googleDriveUrl;

  String _thumbnailDriveUrl = "";
  String get thumbnailDriveUrl => _thumbnailDriveUrl;

  String _examDriveUrl = "";
  String get examDriveUrl => _examDriveUrl;

  String _userNotice = "";
  String get userNotice => _userNotice;

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
        _repository.getGoogleDriveFolderUrl(),
        _repository.getThumbnailDriveUrl(),
        _repository.getExamDriveUrl(),
        _repository.getNotice(),
      ]);
      _entryCode = results[0];
      _userAppUrl = results[1];
      _googleDriveUrl = results[2];
      _thumbnailDriveUrl = results[3];
      _examDriveUrl = results[4];
      _userNotice = results[5];
      _error = null;

      // Initial status check
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

  Future<void> loadEntryCode() async {
    _isLoading = true;
    notifyListeners();

    try {
      _entryCode = await _repository.getEntryCode();
      _error = null;
    } catch (e) {
      _error = "입장 코드를 불러오는데 실패했습니다.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  Future<void> updateUserNotice(String notice) async {
    _isLoading = true;
    notifyListeners();

    try {
      _userNotice = await _repository.updateNotice(notice);
      _error = null;
    } catch (e) {
      _error = "공지사항 업데이트 실패: $e";
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> restartAdminServer() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.restartAdminServer();
    } catch (_) {
    } finally {
      await Future<void>.delayed(const Duration(seconds: 3));
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> restartUserServer() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.restartUserServer();
    } catch (e) {
      debugPrint('Restart User Server Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
