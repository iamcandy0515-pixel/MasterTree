import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_admin_app/features/quiz_management/repositories/quiz_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './services/quiz_extraction_service.dart';

class BulkExtractionViewModel extends ChangeNotifier {
  final QuizRepository _quizRepo = QuizRepository();
  final QuizExtractionService _extractionService = QuizExtractionService();

  BulkExtractionViewModel() {
    loadSavedFilters();
    _loadBackup();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isCancelled = false; // Cancellation Flag
  bool get isCancelled => _isCancelled;

  String _statusMessage = '';
  String get statusMessage => _statusMessage;

  final Map<int, Map<String, dynamic>> _extractedQuizzes = {};
  Map<int, Map<String, dynamic>> get extractedQuizzes => _extractedQuizzes;

  String? subject;
  int? year;
  int? round;
  String? fileId;
  int startNumber = 0;
  int endNumber = 0;

  bool get isFilterComplete =>
      subject != null &&
      year != null &&
      round != null &&
      fileId != null &&
      startNumber > 0 &&
      endNumber > 0 &&
      startNumber <= endNumber;

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

  void cancelExtraction() {
    _isCancelled = true;
    _statusMessage = '추출 중단 요청됨...';
    notifyListeners();
  }

  Future<void> startBatchExtraction({
    required Function(int current, int total) onProgress,
    required Function(String message) onMessage,
  }) async {
    if (!isFilterComplete) {
      onMessage('⚠️ 필터 조건을 모두 올바르게 입력해주세요.');
      return;
    }

    _isLoading = true;
    _isCancelled = false;
    _statusMessage = '추출을 시작합니다...';
    _extractedQuizzes.clear();
    notifyListeners();

    try {
      final totalToExtract = endNumber - startNumber + 1;
      int extractedCount = 0;

      for (int i = startNumber; i <= endNumber; i += 5) {
        if (_isCancelled) {
          onMessage('🛑 사용자에 의해 추출이 중단되었습니다.');
          break;
        }

        int chunkEnd = (i + 4 > endNumber) ? endNumber : i + 4;
        _statusMessage = '진행 중: $i번 ~ $chunkEnd번 추출 중...';
        notifyListeners();

        final batchresults = await _extractionService.extractChunk(
          fileId: fileId!,
          subject: subject!,
          year: year!,
          round: round!,
          start: i,
          end: chunkEnd,
        );

        if (_isCancelled) break;

        _extractedQuizzes.addAll(batchresults);
        extractedCount = _extractedQuizzes.length;
        onProgress(extractedCount, totalToExtract);
        _saveBackup(); // Autosave after each chunk
        notifyListeners();
      }

      if (!_isCancelled) {
        _showExtractionResult(extractedCount, totalToExtract, onMessage);
      }
    } catch (e) {
      _statusMessage = '오류 발생';
      onMessage('❌ 추출 중 오류 발생: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _showExtractionResult(
    int extractedCount,
    int totalToExtract,
    Function(String) onMessage,
  ) {
    if (extractedCount == totalToExtract) {
      _statusMessage = '추출 완료';
      onMessage('🎊 모든 문항($extractedCount건) 추출이 완료되었습니다!');
    } else {
      _statusMessage = '추출 완료 (일부 누락)';
      onMessage('⚠️ 추출 완료 (성공: $extractedCount, 목표: $totalToExtract).');
    }
  }

  void updateQuizContent(int qNum, String field, dynamic value) {
    if (!_extractedQuizzes.containsKey(qNum)) return;

    final item = _extractedQuizzes[qNum]!;
    if (field == 'question' || field == 'explanation') {
      _updateBlockContent(item, field, value.toString());
    } else {
      item[field] = value;
    }

    if (field == 'wrong_answer') _updateWrongOption(item, value.toString());
    _saveBackup(); // Autosave on content update
    notifyListeners();
  }

  void _updateBlockContent(
    Map<String, dynamic> item,
    String field,
    String value,
  ) {
    List blocks = List.from(item[field] ?? []);
    int firstTextIdx = blocks.indexWhere((b) => b['type'] == 'text');
    final newBlock = {'type': 'text', 'content': value};

    if (firstTextIdx >= 0) {
      blocks.removeWhere((b) => b['type'] == 'text');
      blocks.insert(firstTextIdx.clamp(0, blocks.length), newBlock);
    } else {
      blocks.insert(0, newBlock);
    }
    item[field] = blocks;
  }

  void _updateWrongOption(Map<String, dynamic> item, String value) {
    final options = List<String>.from(item['options'] ?? []);
    final cIdx = (item['correct_option_index'] as int?) ?? 0;
    if (options.length >= 2) {
      final wIdx = 1 - cIdx;
      if (wIdx >= 0 && wIdx < options.length) {
        options[wIdx] = value;
        item['options'] = options;
      }
    }
  }

  Future<void> _saveBackup() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _extractedQuizzes.map((k, v) => MapEntry(k.toString(), v));
    await prefs.setString('bulk_extraction_backup', jsonEncode(data));
  }

  Future<void> _loadBackup() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('bulk_extraction_backup');
    if (json != null) {
      final data = jsonDecode(json) as Map<String, dynamic>;
      data.forEach((k, v) {
        _extractedQuizzes[int.parse(k)] = v as Map<String, dynamic>;
      });
      notifyListeners();
    }
  }

  Future<void> addImageToQuiz(int qNum, String field, XFile file) async {
    try {
      _isLoading = true;
      notifyListeners();
      final bytes = await file.readAsBytes();
      final url = await _quizRepo.uploadQuizImage(bytes, file.name);

      final item = _extractedQuizzes.putIfAbsent(
        qNum,
        () => {
          'question_number': qNum,
          'question': [],
          'explanation': [],
          'options': [],
        },
      );
      List blocks = List.from(item[field] ?? []);
      blocks.add({'type': 'image', 'content': url});
      item[field] = blocks;
      _saveBackup();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool hasImage(int qNum, [String? field]) {
    if (!_extractedQuizzes.containsKey(qNum)) return false;
    final quiz = _extractedQuizzes[qNum]!;
    if (field != null) {
      return (quiz[field] as List).any((b) => b['type'] == 'image');
    }
    return (quiz['question'] as List).any((b) => b['type'] == 'image') ||
        (quiz['explanation'] as List).any((b) => b['type'] == 'image');
  }

  void removeImage(int qNum, String field, int index) {
    if (!_extractedQuizzes.containsKey(qNum)) return;
    List blocks = List.from(_extractedQuizzes[qNum]![field] ?? []);
    if (index >= 0 && index < blocks.length) {
      blocks.removeAt(index);
      _extractedQuizzes[qNum]![field] = blocks;
      _saveBackup();
      notifyListeners();
    }
  }

  Future<Map<String, int>> saveAllToDatabase({
    void Function(int current, int total)? onProgress,
    void Function(String message)? onMessage,
  }) async {
    if (_extractedQuizzes.isEmpty || subject == null) {
      return {'total': 0, 'success': 0, 'failed': 0};
    }

    _isLoading = true;
    _statusMessage = '데이터베이스 등록 중...';
    notifyListeners();

    try {
      final entries = _extractedQuizzes.values.toList()
        ..sort(
          (a, b) => (a['question_number'] as int).compareTo(
            b['question_number'] as int,
          ),
        );
      final batchData = _extractionService.prepareBatchForDatabase(entries);

      final examFilter = {'subject': subject, 'year': year, 'round': round};
      final success = await _quizRepo.upsertBatch(
        quizItems: batchData,
        examFilter: examFilter,
      );

      if (success) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('bulk_extraction_backup');
        _extractedQuizzes.clear();
      }

      onMessage?.call(
        success ? '✅ 모든 문항이 성공적으로 등록되었습니다.' : '❌ 등록 중 오류가 발생했습니다.',
      );
      return {
        'total': entries.length,
        'success': success ? entries.length : 0,
        'failed': success ? 0 : entries.length,
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
