import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_admin_app/features/quiz_management/repositories/quiz_repository.dart';
import '../utils/bulk_data_utility.dart';
import 'mixins/bulk_filter_mixin.dart';
import 'mixins/bulk_process_mixin.dart';
import 'mixins/bulk_media_mixin.dart';
import 'mixins/bulk_persistence_mixin.dart';

class BulkExtractionViewModel extends ChangeNotifier
    with BulkFilterMixin, BulkProcessMixin, BulkMediaMixin, BulkPersistenceMixin {
  final QuizRepository _quizRepo = QuizRepository();

  BulkExtractionViewModel() {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadSavedFilters();
    _extractedQuizzes.addAll(await loadBackupLocal());
    notifyListeners();
  }

  // --- Core State ---
  final Map<int, Map<String, dynamic>> _extractedQuizzes = {};
  Map<int, Map<String, dynamic>> get extractedQuizzes => _extractedQuizzes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String get statusMessage => statusMessageText;
  bool get isCancelled => isCancelledFlag;

  // --- UI Action Mapping ---
  void cancelExtraction() => cancelExtractionFlag();

  Future<void> startBatchExtraction({
    required Function(int current, int total) onProgress,
    required Function(String message) onMessage,
  }) async {
    if (!isFilterComplete) {
      onMessage('⚠️ 필터 조건을 모두 올바르게 입력해주세요.');
      return;
    }

    _isLoading = true;
    isCancelledFlag = false;
    statusMessageText = '추출을 시작합니다...';
    _extractedQuizzes.clear();
    notifyListeners();

    try {
      final totalToExtract = endNumber - startNumber + 1;
      for (int i = startNumber; i <= endNumber; i += 5) {
        if (isCancelledFlag) {
          onMessage('🛑 사용자에 의해 추출이 중단되었습니다.');
          break;
        }

        int chunkEnd = (i + 4 > endNumber) ? endNumber : i + 4;
        statusMessageText = '진행 중: $i번 ~ $chunkEnd번 추출 중...';
        notifyListeners();

        final batchResults = await extractionService.extractChunk(
          fileId: fileId!, subject: subject!, year: year!, round: round!,
          start: i, end: chunkEnd,
        );

        if (isCancelledFlag) break;

        _extractedQuizzes.addAll(batchResults);
        onProgress(_extractedQuizzes.length, totalToExtract);
        markDirty();
        await saveBackupLocal(_extractedQuizzes);
        notifyListeners();
      }

      if (!isCancelledFlag) {
        showExtractionResultMsg(_extractedQuizzes.length, totalToExtract, onMessage);
      }
    } catch (e) {
      statusMessageText = '오류 발생';
      onMessage('❌ 추출 중 오류 발생: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateQuizContent(int qNum, String field, dynamic value) {
    if (!_extractedQuizzes.containsKey(qNum)) return;

    var item = _extractedQuizzes[qNum]!;
    if (field == 'question' || field == 'explanation') {
      item = BulkDataUtility.updateBlockContent(item, field, value.toString());
    } else {
      item[field] = value;
    }

    if (field == 'wrong_answer') {
      item = BulkDataUtility.updateWrongOption(item, value.toString());
    }

    _extractedQuizzes[qNum] = item;
    markDirty();
    saveBackupLocal(_extractedQuizzes);
    notifyListeners();
  }

  Future<void> addImageToQuiz(int qNum, String field, XFile file) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final url = await uploadAndAddImage(file);
      if (url == null) return;

      final item = _extractedQuizzes.putIfAbsent(qNum, () => createInitialQuizEntry(qNum));
      List blocks = List.from(item[field] ?? []);
      blocks.add({'type': 'image', 'content': url});
      item[field] = blocks;
      
      markDirty();
      await saveBackupLocal(_extractedQuizzes);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool hasImage(int qNum, [String? field]) => BulkDataUtility.hasImage(_extractedQuizzes, qNum, field);

  void removeImage(int qNum, String field, int index) {
    if (!_extractedQuizzes.containsKey(qNum)) return;
    List blocks = List.from(_extractedQuizzes[qNum]![field] ?? []);
    if (index >= 0 && index < blocks.length) {
      blocks.removeAt(index);
      _extractedQuizzes[qNum]![field] = blocks;
      markDirty();
      saveBackupLocal(_extractedQuizzes);
      notifyListeners();
    }
  }

  Future<Map<String, int>> saveAllToDatabase({
    void Function(int current, int total)? onProgress,
    void Function(String message)? onMessage,
  }) async {
    if (_extractedQuizzes.isEmpty || subject == null) return {'total': 0, 'success': 0, 'failed': 0};

    _isLoading = true;
    statusMessageText = '데이터베이스 등록 중...';
    notifyListeners();

    try {
      final entries = _extractedQuizzes.values.toList()..sort((a, b) => (a['question_number'] as int).compareTo(b['question_number'] as int));
      final batchData = extractionService.prepareBatchForDatabase(entries);

      final success = await _quizRepo.upsertBatch(
        quizItems: batchData,
        examFilter: {'subject': subject, 'year': year, 'round': round},
      );

      if (success) {
        await clearBackupLocal();
        _extractedQuizzes.clear();
      }

      onMessage?.call(success ? '✅ 모든 문항이 성공적으로 등록되었습니다.' : '❌ 등록 중 오류가 발생했습니다.');
      return {'total': entries.length, 'success': success ? entries.length : 0, 'failed': success ? 0 : entries.length};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
