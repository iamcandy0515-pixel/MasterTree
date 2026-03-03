import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_admin_app/features/quiz_management/repositories/quiz_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BulkExtractionViewModel extends ChangeNotifier {
  final QuizRepository _quizRepo = QuizRepository();

  BulkExtractionViewModel() {
    loadSavedFilters();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _statusMessage = '';
  String get statusMessage => _statusMessage;

  // Key: question_number, Value: Quiz Data Map
  final Map<int, Map<String, dynamic>> _extractedQuizzes = {};
  Map<int, Map<String, dynamic>> get extractedQuizzes => _extractedQuizzes;

  bool get isFilterComplete =>
      subject != null &&
      year != null &&
      round != null &&
      fileId != null &&
      startNumber > 0 &&
      endNumber > 0 &&
      startNumber <= endNumber;

  // Current filter state
  String? subject;
  int? year;
  int? round;
  String? fileId;
  int startNumber = 0;
  int endNumber = 0;

  void updateFilters({
    String? subject,
    int? year,
    int? round,
    String? fileId,
    int? start,
    int? end,
  }) {
    if (subject != null) this.subject = subject;
    if (year != null) this.year = year;
    if (round != null) this.round = round;
    if (fileId != null) this.fileId = fileId;
    if (start != null) startNumber = start;
    if (end != null) endNumber = end;

    _saveFilters();
    notifyListeners();
  }

  Future<void> loadSavedFilters() async {
    final prefs = await SharedPreferences.getInstance();
    subject = prefs.getString('ext_filter_subject');
    year = prefs.getInt('ext_filter_year');
    round = prefs.getInt('ext_filter_round');
    fileId = prefs.getString('ext_filter_file_id');
    startNumber = prefs.getInt('ext_filter_start') ?? 0;
    endNumber = prefs.getInt('ext_filter_end') ?? 0;
    notifyListeners();
  }

  Future<void> _saveFilters() async {
    final prefs = await SharedPreferences.getInstance();
    if (subject != null) await prefs.setString('ext_filter_subject', subject!);
    if (year != null) await prefs.setInt('ext_filter_year', year!);
    if (round != null) await prefs.setInt('ext_filter_round', round!);
    if (fileId != null) await prefs.setString('ext_filter_file_id', fileId!);
    await prefs.setInt('ext_filter_start', startNumber);
    await prefs.setInt('ext_filter_end', endNumber);
  }

  /// Start the batch extraction process with automatic chunking (5 items per chunk)
  Future<void> startBatchExtraction({
    required Function(int current, int total) onProgress,
    required Function(String message) onMessage,
  }) async {
    // 1. Validation
    if (fileId == null || subject == null || year == null || round == null) {
      onMessage('⚠️ 필터 조건을 모두 입력해주세요.');
      return;
    }

    if (startNumber <= 0 || endNumber <= 0) {
      onMessage('⚠️ 추출 범위를 먼저 입력해주세요 (1 이상의 숫자).');
      return;
    }

    if (startNumber > endNumber) {
      onMessage('⚠️ 시작 번호가 종료 번호보다 큽니다.');
      return;
    }

    _isLoading = true;
    _statusMessage = '추출을 시작합니다...';
    _extractedQuizzes.clear();
    notifyListeners();

    try {
      final totalToExtract = endNumber - startNumber + 1;
      final Set<int> expectedNums = {
        for (int i = startNumber; i <= endNumber; i++) i,
      };

      List<List<int>> chunks = [];
      for (int i = startNumber; i <= endNumber; i += 5) {
        int chunkEnd = (i + 4 > endNumber) ? endNumber : i + 4;
        chunks.add([i, chunkEnd]);
      }

      int extractedCount = 0;
      for (int i = 0; i < chunks.length; i++) {
        final chunk = chunks[i];
        _statusMessage =
            '진행 중: ${chunk[0]}번 ~ ${chunk[1]}번 추출 중... (${i + 1}/${chunks.length})';
        notifyListeners();

        final batchData = await _quizRepo.extractBatch(
          fileId: fileId!,
          startNumber: chunk[0],
          endNumber: chunk[1],
          subject: subject!,
          year: year!,
          round: round!,
        );

        for (var item in batchData) {
          final qNumRaw = item['question_number'];
          final qNum = qNumRaw is int
              ? qNumRaw
              : int.tryParse(qNumRaw?.toString() ?? '') ?? 0;
          if (qNum <= 0) continue;

          String explanation =
              (item['explanation_blocks'] ?? item['explanation'] ?? '')
                  .toString();
          explanation = explanation
              .split('\n')
              .where(
                (line) => !line.contains('해당사항 없음') && !line.contains('필요 없음'),
              )
              .join('\n')
              .replaceAll(RegExp(r'\n{3,}'), '\n\n')
              .trim();

          final Map<String, dynamic> mappedItem = {
            'question_number': qNum,
            'question': item['content_blocks'] ?? item['question'] ?? [],
            'explanation':
                item['explanation_blocks'] ?? item['explanation'] ?? [],
            'hint': (item['hint_blocks'] is List)
                ? (item['hint_blocks'] as List)
                      .map(
                        (h) => h is Map
                            ? (h['content']?.toString() ?? '')
                            : h.toString(),
                      )
                      .join('\n')
                : (item['hint'] ?? ''),
            'correct_option_index': 0,
            'options': item['options'] ?? [],
          };

          // If question/explanation are strings, convert to blocks
          if (mappedItem['question'] is String) {
            mappedItem['question'] = [
              {'type': 'text', 'content': mappedItem['question']},
            ];
          } else if (mappedItem['question'] is! List) {
            mappedItem['question'] = [
              {
                'type': 'text',
                'content': mappedItem['question']?.toString() ?? '',
              },
            ];
          }

          if (mappedItem['explanation'] is String) {
            mappedItem['explanation'] = [
              {'type': 'text', 'content': mappedItem['explanation']},
            ];
          } else if (mappedItem['explanation'] is! List) {
            mappedItem['explanation'] = [
              {
                'type': 'text',
                'content': mappedItem['explanation']?.toString() ?? '',
              },
            ];
          }

          // Ensure if list is empty but we have item['question'] string
          if ((mappedItem['question'] as List).isEmpty &&
              item['question'] != null) {
            mappedItem['question'] = [
              {'type': 'text', 'content': item['question'].toString()},
            ];
          }
          if ((mappedItem['explanation'] as List).isEmpty &&
              explanation.isNotEmpty) {
            mappedItem['explanation'] = [
              {'type': 'text', 'content': explanation},
            ];
          }

          final cIdxRaw = item['correct_option_index'];
          mappedItem['correct_option_index'] = cIdxRaw is int
              ? cIdxRaw
              : int.tryParse(cIdxRaw?.toString() ?? '') ?? 0;

          final options = mappedItem['options'] as List;
          final cIdx = mappedItem['correct_option_index'] as int;
          if (options.length >= 2) {
            final wIdx = 1 - cIdx;
            if (wIdx >= 0 && wIdx < options.length) {
              mappedItem['wrong_answer'] = options[wIdx].toString();
            }
          }
          _extractedQuizzes[qNum] = mappedItem;
          extractedCount++;

          // Debugging log for extraction verification
          debugPrint(
            '🎯 [Extraction Success] Key parts: ($subject, $year, $round, Q$qNum)',
          );
        }

        // 5건 주기 혹은 청크 단위로 알림
        onProgress(extractedCount, totalToExtract);
        notifyListeners();
      }

      // Check for missing numbers
      final List<int> missingNums =
          expectedNums
              .where((num) => !_extractedQuizzes.containsKey(num))
              .toList()
            ..sort();

      if (missingNums.isEmpty) {
        _statusMessage = '모든 문항 추출이 완료되었습니다.';
        onMessage('🎊 모든 문항($extractedCount건) 추출이 완료되었습니다!');
      } else {
        final failedCount = missingNums.length;
        _statusMessage = '추출 완료 (일부 누락)';
        onMessage(
          '⚠️ 추출 완료 (성공: $extractedCount, 누락: $failedCount).\n누락 번호: ${missingNums.join(', ')}',
        );
      }
    } catch (e) {
      _statusMessage = '오류 발생: ${e.toString()}';
      onMessage('❌ 추출 중 오류 발생: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update a specific quiz content in the local state (during editing)
  void updateQuizContent(int qNum, String field, dynamic value) {
    if (!_extractedQuizzes.containsKey(qNum)) {
      _extractedQuizzes[qNum] = {
        'question_number': qNum,
        'question': [],
        'explanation': [],
        'hint': '',
        'options': [],
      };
    }

    final item = _extractedQuizzes[qNum]!;

    if (field == 'question' || field == 'explanation') {
      // 텍스트 수정을 할 때, 기존 블록들 중 텍스트 블록들을 하나로 합치고 나머지는 유지합니다.
      List blocks = List.from(item[field] ?? []);

      // 이미지 블록들만 따로 보관
      List imageBlocks = blocks.where((b) => b['type'] == 'image').toList();

      // 새로운 텍스트 블록 생성 (모든 텍스트를 하나로 합친 상태에서 수정된 값 적용)
      Map<String, dynamic> newTextBlock = {
        'type': 'text',
        'content': value.toString(),
      };

      // 결과 블록 리스트 생성: 텍스트를 맨 앞에 두고 이미지를 뒤에 붙임 (간단한 동기화 방식)
      // 또는 기존의 첫 번째 텍스트 블록 위치를 유지하고 싶다면:
      int firstTextIdx = blocks.indexWhere((b) => b['type'] == 'text');
      if (firstTextIdx >= 0) {
        // 기존 텍스트 블록들 다 제거
        blocks.removeWhere((b) => b['type'] == 'text');
        // 그 위치에 새 텍스트 삽입
        blocks.insert(firstTextIdx.clamp(0, blocks.length), newTextBlock);
        item[field] = blocks;
      } else {
        // 텍스트 블록이 없었으면 맨 앞에 추가
        item[field] = [newTextBlock, ...imageBlocks];
      }
    } else {
      item[field] = value;
    }

    if (field == 'wrong_answer') {
      final options = List<String>.from(item['options'] ?? []);
      final cIdx = (item['correct_option_index'] as int?) ?? 0;
      if (options.length >= 2) {
        final wIdx = 1 - cIdx;
        if (wIdx >= 0 && wIdx < options.length) {
          options[wIdx] = value.toString();
          item['options'] = options;
        }
      }
    }
    notifyListeners();
  }

  /// 퀴즈에 이미지 추가
  Future<void> addImageToQuiz(int qNum, String field, XFile file) async {
    try {
      _isLoading = true;
      notifyListeners();

      final bytes = await file.readAsBytes();
      final url = await _quizRepo.uploadQuizImage(bytes, file.name);

      if (!_extractedQuizzes.containsKey(qNum)) {
        _extractedQuizzes[qNum] = {
          'question_number': qNum,
          'question': [],
          'explanation': [],
          'options': [],
        };
      }

      final item = _extractedQuizzes[qNum]!;
      List blocks = List.from(item[field] ?? []);
      blocks.add({'type': 'image', 'content': url});
      item[field] = blocks;

      notifyListeners();
    } catch (e) {
      debugPrint('Image Upload Error: $e');
      rethrow; // Re-throw to show error in UI SnackBar
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 퀴즈에 이미지가 있는지 확인 (UI 가시성 제어용)
  bool hasImage(int qNum, [String? field]) {
    if (!_extractedQuizzes.containsKey(qNum)) return false;
    final quiz = _extractedQuizzes[qNum]!;
    if (field != null) {
      final List blocks = quiz[field] ?? [];
      return blocks.any((b) => b['type'] == 'image');
    }
    // Check both question and explanation
    final List qBlocks = quiz['question'] ?? [];
    final List eBlocks = quiz['explanation'] ?? [];
    return qBlocks.any((b) => b['type'] == 'image') ||
        eBlocks.any((b) => b['type'] == 'image');
  }

  /// 퀴즈에서 이미지 제거
  void removeImage(int qNum, String field, int index) {
    if (!_extractedQuizzes.containsKey(qNum)) return;
    final item = _extractedQuizzes[qNum]!;
    List blocks = List.from(item[field] ?? []);
    if (index >= 0 && index < blocks.length) {
      blocks.removeAt(index);
      item[field] = blocks;
      notifyListeners();
    }
  }

  /// Save all extracted quizzes to database with chunking (5 items per batch)
  Future<Map<String, int>> saveAllToDatabase({
    void Function(int current, int total)? onProgress,
    void Function(String message)? onMessage,
  }) async {
    if (_extractedQuizzes.isEmpty) {
      return {'total': 0, 'success': 0, 'failed': 0};
    }

    // [Strict Key Validation]
    if (subject == null || year == null || round == null) {
      onMessage?.call('필수 key 에러: 과목, 년도, 회차 정보가 없습니다.');
      return {'total': 0, 'success': 0, 'failed': 0};
    }

    _isLoading = true;
    _statusMessage = '데이터베이스 등록 중...';
    notifyListeners();

    int total = _extractedQuizzes.length;
    int successCount = 0;
    int failedCount = 0;

    onMessage?.call('DB 등록을 시작합니다... (총 $total건)');

    try {
      final quizEntries = _extractedQuizzes.values.toList()
        ..sort(
          (a, b) => (a['question_number'] as int).compareTo(
            b['question_number'] as int,
          ),
        );

      // Process in chunks of 5
      for (int i = 0; i < total; i += 5) {
        int end = (i + 5 < total) ? i + 5 : total;
        List<Map<String, dynamic>> chunk = quizEntries.sublist(i, end).map((
          quiz,
        ) {
          final qNum = quiz['question_number'];
          if (qNum == null || qNum == 0) {
            throw Exception('필수 key 에러: 문제 번호 누락');
          }
          final List contentBlocks = quiz['question'] ?? [];
          final List explanationBlocks = quiz['explanation'] ?? [];

          final Map<String, dynamic> body = {
            'question_number': qNum,
            'content_blocks': contentBlocks,
            'explanation_blocks': explanationBlocks,
            'correct_option_index': quiz['correct_option_index'],
            'options': quiz['options'],
            'status': 'active', // 추출/편집 완료 시 바로 활성화
          };

          final hintStr = quiz['hint']?.toString() ?? '';
          body['hint_blocks'] = hintStr.isNotEmpty
              ? hintStr
                    .split('\n')
                    .where((h) => h.trim().isNotEmpty)
                    .map((h) => {'type': 'text', 'content': h})
                    .toList()
              : [];

          return body;
        }).toList();

        onMessage?.call('문항 등록 중... ($end/$total)');
        final examFilter = {'subject': subject, 'year': year, 'round': round};

        final success = await _quizRepo.upsertBatch(
          quizItems: chunk,
          examFilter: examFilter,
        );

        if (success) {
          successCount += chunk.length;
        } else {
          failedCount += chunk.length;
        }

        onProgress?.call(end, total);
        notifyListeners();
      }

      _statusMessage = '성공적으로 DB에 등록되었습니다.';
      return {'total': total, 'success': successCount, 'failed': failedCount};
    } catch (e) {
      debugPrint('Batch Upsert Error: $e');
      final errorMsg = e.toString();
      if (errorMsg.contains('필수 key 에러')) {
        onMessage?.call('⚠️ 필수 key 에러: 등록 정보가 부족합니다.');
      }
      _statusMessage = 'DB 등록 실패: $errorMsg';
      return {
        'total': total,
        'success': successCount,
        'failed': total - successCount,
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
