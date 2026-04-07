import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'quiz_service.dart';
import '../../utils/app_logger.dart';

class SyncService {
  static final List<Map<String, dynamic>> _pendingAttempts = [];
  static const String _storageKey = 'KEY_PENDING_QUIZ_ATTEMPTS';

  /// SyncService 초기화 (로컬 캐시 로드)
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString(_storageKey);
      if (savedData != null) {
        final List<dynamic> decoded = jsonDecode(savedData) as List<dynamic>;
        _pendingAttempts.clear();
        _pendingAttempts.addAll(decoded.cast<Map<String, dynamic>>());
        AppLogger.d('로컬 캐시 로드됨: ${_pendingAttempts.length}개', tag: 'SYNC');
      }
    } catch (e) {
      AppLogger.e('SyncService.init Error', error: e);
    }
  }

  /// 보류 중인 학습 결과 로컬 저장
  static Future<void> _persistAttempts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_pendingAttempts.isEmpty) {
        await prefs.remove(_storageKey);
      } else {
        await prefs.setString(_storageKey, jsonEncode(_pendingAttempts));
      }
    } catch (e) {
      AppLogger.e('SyncService._persistAttempts Error', error: e);
    }
  }

  /// 보류 중인 학습 결과 추가
  static void addPendingAttempt(Map<String, dynamic> attempt) {
    _pendingAttempts.add(attempt);
    _persistAttempts(); // 즉시 로컬 저장
    AppLogger.d('보류 중인 학습 결과 추가 및 저장됨 (현재: ${_pendingAttempts.length}개)', tag: 'SYNC');
  }

  /// 보류 중인 모든 학습 결과를 서버로 전송 (동기화)
  static Future<void> syncPendingAttempts() async {
    if (_pendingAttempts.isEmpty) return;
    AppLogger.d('학습 결과 동기화 시작 (${_pendingAttempts.length}개)', tag: 'SYNC');

    final attemptsToSync = List<Map<String, dynamic>>.from(_pendingAttempts);
    final success = await QuizService.submitBatchAttempts(attemptsToSync);

    if (success) {
      _pendingAttempts.clear();
      await _persistAttempts(); // 전송 성공 시 로컬 캐시 삭제
      AppLogger.d('학습 결과 동기화 성공 및 캐시 삭제됨', tag: 'SYNC');
    } else {
      AppLogger.d('학습 결과 동기화 실패 (로컬 유지)', tag: 'SYNC');
    }
  }
}
