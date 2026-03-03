import 'package:flutter/material.dart';
import '../../trees/repositories/tree_repository.dart';

class SettingsViewModel extends ChangeNotifier {
  final TreeRepository _repository = TreeRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isInitialLoading = true;
  bool get isInitialLoading => _isInitialLoading;

  String? _error;
  String? get error => _error;

  String _entryCode = "1234";
  String get entryCode => _entryCode;

  String _userAppUrl = "http://localhost:8080";
  String get userAppUrl => _userAppUrl;

  String _googleDriveUrl = "";
  String get googleDriveUrl => _googleDriveUrl;

  Future<void> loadSettings() async {
    _isLoading = true;
    _isInitialLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.getEntryCode(),
        _repository.getUserAppUrl(),
        _repository.getGoogleDriveFolderUrl(),
      ]);
      _entryCode = results[0];
      _userAppUrl = results[1];
      _googleDriveUrl = results[2];
      _error = null;
    } catch (e) {
      _error = "설정 정보를 불러오는데 실패했습니다.";
    } finally {
      _isLoading = false;
      _isInitialLoading = false;
      notifyListeners();
    }
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
    } catch (e) {
      _error = "구글 드라이브 URL 수정에 실패했습니다: $e";
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
      _error = null;
    } catch (e) {
      _error = "관리자 서버 재시작 요청 실패: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> restartUserServer() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.restartUserServer();
      _error = null;
    } catch (e) {
      _error = "사용자 서버 재시작 요청 실패: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
