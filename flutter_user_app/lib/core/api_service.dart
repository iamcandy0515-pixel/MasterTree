import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class ApiService {
  static Future<List<Map<String, dynamic>>> getTrees({
    int page = 1,
    int limit = 100,
    String? search,
    String? category,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
      if (category != null && category != '전체') 'category': category,
    };

    final url = Uri.parse(
      '${AppConstants.apiUrl}/trees',
    ).replace(queryParameters: queryParams);

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'];
          // Convert to List<Map<String, dynamic>>
          return data.map((e) {
            final tree = Map<String, dynamic>.from(e);
            // Handle image_url flattening if needed by screens
            final images = tree['tree_images'] as List<dynamic>?;
            if (images != null && images.isNotEmpty) {
              final mainImg = images.firstWhere(
                (img) => img['image_type'] == 'main',
                orElse: () => images[0],
              );
              tree['image_url'] = mainImg['image_url'];
            }
            return tree;
          }).toList();
        }
      }
      throw Exception('Failed to load trees: ${response.body}');
    } catch (e) {
      debugPrint('ApiService.getTrees Error: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getTreeImages(int treeId) async {
    // Note: The /api/trees standard response already includes images.
    final url = Uri.parse('${AppConstants.apiUrl}/trees?search=$treeId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['success'] == true &&
            jsonResponse['data'].isNotEmpty) {
          return List<Map<String, dynamic>>.from(
            jsonResponse['data'][0]['tree_images'] ?? [],
          );
        }
      }
    } catch (e) {
      debugPrint('ApiService.getTreeImages Error: $e');
    }
    return [];
  }

  /// 외부 이미지를 위한 프록시 URL 반환
  static String getProxyImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    // 이미 프록시된 URL이거나 드라이브 링크가 아니면 그대로 반환
    if (url.contains('/uploads/proxy') || !url.contains('drive.google.com')) {
      return url;
    }
    return '${AppConstants.apiUrl}/uploads/proxy?url=${Uri.encodeComponent(url)}';
  }

  /// 유사종 비교 그룹 리스트 가져오기
  static Future<List<Map<String, dynamic>>> getTreeGroups() async {
    final url = Uri.parse('${AppConstants.apiUrl}/tree-groups');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['success'] == true) {
          return List<Map<String, dynamic>>.from(jsonResponse['data'] ?? []);
        }
      }
      throw Exception('Failed to load groups: ${response.body}');
    } catch (e) {
      debugPrint('ApiService.getTreeGroups Error: $e');
      rethrow;
    }
  }

  /// 특정 유사종 비교 그룹 가져오기
  static Future<Map<String, dynamic>> getTreeGroup(String id) async {
    final url = Uri.parse('${AppConstants.apiUrl}/tree-groups/$id');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['success'] == true) {
          return Map<String, dynamic>.from(jsonResponse['data'] ?? {});
        }
      }
      throw Exception('Failed to load group: ${response.body}');
    } catch (e) {
      debugPrint('ApiService.getTreeGroup Error: $e');
      rethrow;
    }
  }

  /// 사용자 대시보드 통계 가져오기
  static Future<Map<String, dynamic>> getUserStats() async {
    final url = Uri.parse('${AppConstants.apiUrl}/stats/user');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['success'] == true) {
          return Map<String, dynamic>.from(jsonResponse['data'] ?? {});
        }
      }
      throw Exception('Failed to load stats: ${response.body}');
    } catch (e) {
      debugPrint('ApiService.getUserStats Error: $e');
      rethrow;
    }
  }

  /// 사용자 개인 학습 성취도 통계 가져오기 (퀴즈, 기출)
  static Future<Map<String, dynamic>> getUserPerformanceStats() async {
    final url = Uri.parse('${AppConstants.apiUrl}/stats/performance');
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken ?? '';

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['success'] == true) {
          return Map<String, dynamic>.from(jsonResponse['data'] ?? {});
        }
      }
      throw Exception('상태 코드: ${response.statusCode}');
    } catch (e) {
      debugPrint('ApiService.getUserPerformanceStats Error: $e');
      rethrow;
    }
  }

  static final List<Map<String, dynamic>> _pendingAttempts = [];
  static const String _storageKey = 'KEY_PENDING_QUIZ_ATTEMPTS';

  /// ApiService 초기화 (로컬 캐시 로드)
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString(_storageKey);
      if (savedData != null) {
        final List<dynamic> decoded = jsonDecode(savedData);
        _pendingAttempts.clear();
        _pendingAttempts.addAll(decoded.cast<Map<String, dynamic>>());
        debugPrint('로컬 캐시 로드됨: ${_pendingAttempts.length}개');
      }
    } catch (e) {
      debugPrint('ApiService.init Error: $e');
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
      debugPrint('ApiService._persistAttempts Error: $e');
    }
  }

  /// 보류 중인 학습 결과 추가
  static void addPendingAttempt(Map<String, dynamic> attempt) {
    _pendingAttempts.add(attempt);
    _persistAttempts(); // 즉시 로컬 저장
    debugPrint('보류 중인 학습 결과 추가 및 저장됨 (현재: ${_pendingAttempts.length}개)');
  }

  /// 보류 중인 모든 학습 결과를 서버로 전송 (동기화)
  static Future<void> syncPendingAttempts() async {
    if (_pendingAttempts.isEmpty) return;
    debugPrint('학습 결과 동기화 시작 (${_pendingAttempts.length}개)');

    final attemptsToSync = List<Map<String, dynamic>>.from(_pendingAttempts);
    final success = await submitBatchAttempts(attemptsToSync);

    if (success) {
      _pendingAttempts.clear();
      await _persistAttempts(); // 전송 성공 시 로컬 캐시 삭제
      debugPrint('학습 결과 동기화 성공 및 캐시 삭제됨');
    } else {
      debugPrint('학습 결과 동기화 실패 (로컬 유지)');
    }
  }

  /// 퀴즈 풀이 결과 단건 저장
  static Future<void> submitQuizAttempt({
    required int questionId,
    required bool isCorrect,
    required String userAnswer,
    int? categoryId,
    int? sessionId,
    int timeTakenMs = 0,
  }) async {
    final url = Uri.parse('${AppConstants.apiUrl}/user-quiz/attempt');
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken ?? '';

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'question_id': questionId,
          'session_id': sessionId,
          'category_id': categoryId,
          'is_correct': isCorrect,
          'user_answer': userAnswer,
          'time_taken_ms': timeTakenMs,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint('학습 결과 저장 실패: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('ApiService.submitQuizAttempt Error: $e');
    }
  }

  /// 특정 세션의 퀴즈 풀이 결과 일괄 저장 (Batch Submit)
  static Future<bool> submitQuizSessionAttempts({
    required int sessionId,
    required List<Map<String, dynamic>> attempts,
  }) async {
    final url = Uri.parse('${AppConstants.apiUrl}/user-quiz/submit');
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken ?? '';

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'session_id': sessionId,
          'attempts': attempts,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint('세션 결과 제출 실패: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('ApiService.submitQuizSessionAttempts Error: $e');
      return false;
    }
  }

  /// 퀴즈 풀이 결과 묶음(배치) 저장
  static Future<bool> submitBatchAttempts(
    List<Map<String, dynamic>> attempts,
  ) async {
    if (attempts.isEmpty) return true;
    final url = Uri.parse('${AppConstants.apiUrl}/user-quiz/batch');
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken ?? '';

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'attempts': attempts}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint(
          '학습 결과 배치 저장 실패: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('ApiService.submitBatchAttempts Error: $e');
      return false;
    }
  }

  /// 퀴즈 세션 생성 (질문 목록 가져오기)
  static Future<Map<String, dynamic>> generateQuizSession({
    String mode = 'normal',
    int limit = 10,
  }) async {
    final url = Uri.parse('${AppConstants.apiUrl}/user-quiz/generate');
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken ?? '';

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'mode': mode,
          'limit': limit,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['success'] == true) {
          return Map<String, dynamic>.from(jsonResponse['data'] ?? {});
        }
      }
      throw Exception('세션 생성 실패: ${response.body}');
    } catch (e) {
      debugPrint('ApiService.generateQuizSession Error: $e');
      rethrow;
    }
  }
}
