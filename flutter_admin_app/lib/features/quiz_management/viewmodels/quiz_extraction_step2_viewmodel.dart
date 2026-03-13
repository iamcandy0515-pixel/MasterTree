import 'package:flutter/material.dart';
import '../models/drive_file.dart';
import '../../quiz_management/repositories/quiz_repository.dart';

class QuizExtractionStep2ViewModel extends ChangeNotifier {
  final QuizRepository _repository = QuizRepository();

  int _hintsCount = 2;
  int get hintsCount => _hintsCount;

  int _selectedQuestion = 1;
  int get selectedQuestion => _selectedQuestion;

  final bool _isExtracting = false;
  bool get isExtracting => _isExtracting;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  bool _isReviewing = false;
  bool get isReviewing => _isReviewing;

  bool _isRecommending = false;
  bool get isRecommending => _isRecommending;

  bool? _searchSuccess;
  bool? get searchSuccess => _searchSuccess;

  String? _selectedFileId;
  String? get selectedFileId => _selectedFileId;

  List<DriveFile> _driveFiles = [];
  List<DriveFile> get driveFiles => _driveFiles;

  Map<String, dynamic>? _extractedBlock;
  Map<String, dynamic>? get extractedBlock => _extractedBlock;

  List<Map<String, dynamic>> _relatedQuestions = [];
  List<Map<String, dynamic>> get relatedQuestions => _relatedQuestions;

  String? _extractedSubject;
  String? get extractedSubject => _extractedSubject;

  int? _extractedYear;
  int? get extractedYear => _extractedYear;

  int? _extractedRound;
  int? get extractedRound => _extractedRound;

  String? _extractedFilterRawString;
  String? get extractedFilterRawString => _extractedFilterRawString;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  double _extractionProgress = 0.0;
  double get extractionProgress => _extractionProgress;

  List<Map<String, dynamic>> get relatedQuizzes => _relatedQuestions;

  String? get selectedSubject => _initialSubject;
  int? get selectedYear => _initialYear;
  int? get selectedRound => _initialRound;
  int get selectedQuestionNumber => _selectedQuestion;

  int _correctOptionIndex = 0;
  int get correctOptionIndex => _correctOptionIndex;

  String? _initialSubject;
  String? get initialSubject => _initialSubject;

  int? _initialYear;
  int? get initialYear => _initialYear;

  int? _initialRound;
  int? get initialRound => _initialRound;

  void setHintsCount(int count) {
    if (count > 0 && count <= 5) {
      _hintsCount = count;
      notifyListeners();
    }
  }

  void setInitialFilter(String? subject, int? year, int? round) {
    _initialSubject = subject;
    _initialYear = year;
    _initialRound = round;
  }

  void setInitialFiles(List<DriveFile> files) {
    if (files.isNotEmpty) {
      _driveFiles = files;
      _selectedFileId = files.first.id;
      notifyListeners();
    }
  }

  void setSelectedQuestion(int question) {
    _selectedQuestion = question;
    notifyListeners();
  }

  void setSelectedFileId(String id) {
    _selectedFileId = id;
    notifyListeners();
  }

  void setMetadata(String subject, int year, int round) {
    _extractedSubject = subject;
    _extractedYear = year;
    _extractedRound = round;
    notifyListeners();
  }

  void setExtractedSubject(String subject) {
    _extractedSubject = subject;
    notifyListeners();
  }

  void setExtractedYear(int year) {
    _extractedYear = year;
    notifyListeners();
  }

  void setExtractedRound(int round) {
    _extractedRound = round;
    notifyListeners();
  }

  void updateFilters({
    String? subject,
    int? year,
    int? round,
    int? questionNumber,
  }) {
    if (subject != null) _initialSubject = subject;
    if (year != null) _initialYear = year;
    if (round != null) _initialRound = round;
    if (questionNumber != null) _selectedQuestion = questionNumber;
    notifyListeners();
  }

  Future<void> searchFiles(String keyword) async {
    if (keyword.isEmpty) {
      throw '검색할 키워드를 입력해주세요.';
    }

    _isSearching = true;
    _searchSuccess = null;
    _driveFiles = [];
    _selectedFileId = null;
    notifyListeners();

    try {
      final results = await _repository.searchDriveFiles(keyword);
      _driveFiles = results.map((e) => DriveFile.fromJson(e)).toList();
      if (_driveFiles.isNotEmpty) {
        _selectedFileId = _driveFiles.first.id;
        _searchSuccess = true;
      } else {
        _searchSuccess = false;
      }
    } catch (e) {
      _searchSuccess = false;
      throw e.toString();
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  bool _isValidating = false;
  bool get isValidating => _isValidating;

  Map<String, dynamic>? _validatedQuizData;

  Future<void> validateFile(String? fallbackFileId) async {
    String? targetFileId = _selectedFileId ?? fallbackFileId;

    if (targetFileId == null) {
      throw '검증할 파일을 먼저 검색하거나 선택해주세요.';
    }

    _isValidating = true;
    notifyListeners();

    try {
      final result = await _repository.validateDriveFile(
        targetFileId,
        subject: _initialSubject,
        year: _initialYear,
        round: _initialRound,
      );

      final valData = result['validation'];

      if (valData is Map) {
        final sbj = valData['extracted_subject']?.toString() ?? '';
        final yr = valData['extracted_year']?.toString() ?? '';
        final rd = valData['extracted_round']?.toString() ?? '';

        final filterParts = [sbj, yr, rd].where((e) => e.isNotEmpty).toList();
        if (filterParts.isNotEmpty) {
          _extractedFilterRawString = filterParts.join(', ');
        } else {
          _extractedFilterRawString = null;
        }

        // Also check AI backend boolean
        final bool filterMatched = valData['filter_matched'] ?? true;
        if (!filterMatched) {
          final String mismatchReason =
              valData['mismatch_reason']?.toString() ?? '';
          throw mismatchReason.isNotEmpty
              ? mismatchReason
              : 'AI 판독 결과 문제가 확인되지 않았습니다.';
        }
      } else {
        throw '검증에 실패했습니다. (잘못된 응답 데이터)';
      }
    } catch (e) {
      if (e.toString().contains('Failed to fetch')) {
        throw '백엔드 서버와 연결할 수 없거나 서버 응답 시간이 초과되었습니다. 서버 실행 상태를 확인하세요.';
      }
      throw e.toString();
    } finally {
      _isValidating = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> extractQuiz() async {
    if (_selectedFileId == null) {
      throw '파일을 먼저 검색하여 선택해주세요.';
    }

    try {
      final result = await _repository.extractDriveFile(
        _selectedFileId!,
        _selectedQuestion,
        _hintsCount,
      );

      final extractedData = result['extractedData'];

      if (extractedData is Map &&
          extractedData['error'] != null &&
          extractedData['error'] != "") {
        throw extractedData['error'];
      }

      final dataBlocks = extractedData['data'] as List?;
      if (dataBlocks != null && dataBlocks.isNotEmpty) {
        _validatedQuizData = dataBlocks.first;

        // Developer logging for verification
        debugPrint(
          '🎯 [Single Extraction Log] Key parts: ($_initialSubject, $_initialYear, $_initialRound, Q$_selectedQuestion)',
        );

        return _validatedQuizData!;
      } else {
        throw '해당 문제 번호가 존재하지 않거나 추출에 실패했습니다.';
      }
    } catch (e) {
      if (e.toString().contains('Failed to fetch')) {
        throw '백엔드 서버와 연결할 수 없거나 서버 응답 시간이 초과되었습니다. 서버 실행 상태를 확인하세요.';
      }
      throw e.toString();
    }
  }

  // Deprecated UI call map, kept for legacy if needed or directly replace in UI.
  Map<String, dynamic> populateExtractedQuiz() {
    if (_validatedQuizData == null) {
      throw '문제를 먼저 추출해주세요.';
    }
    _extractedBlock = _validatedQuizData;
    _correctOptionIndex = _validatedQuizData!['correct_option_index'] ?? 0;
    notifyListeners();
    return _validatedQuizData!;
  }

  Future<void> recommendRelatedAction(String questionText) async {
    if (questionText.isEmpty) {
      throw '문제를 먼저 추출하거나 입력해주세요.';
    }

    _isRecommending = true;
    notifyListeners();

    try {
      final related = await _repository.recommendRelated(
        questionText: questionText,
        limit: 10,
      );
      _relatedQuestions = List<Map<String, dynamic>>.from(related);
    } catch (e) {
      throw e.toString();
    } finally {
      _isRecommending = false;
      notifyListeners();
    }
  }

  Future<List<String>> generateDistractorsAction(
    String questionText,
    String correctAnswer,
  ) async {
    if (questionText.isEmpty || correctAnswer.isEmpty) {
      throw '문제와 현재 지정된 정답 내용을 확인해주세요.';
    }

    try {
      return await _repository.generateDistractors(questionText, correctAnswer);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<String>> generateHintsAction(
    String questionText,
    String explanation,
  ) async {
    if (questionText.isEmpty || explanation.isEmpty) {
      throw '문제와 해설 내용을 먼저 확인해주세요.';
    }

    try {
      return await _repository.generateHints(
        questionText,
        explanation,
        _hintsCount,
      );
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> reviewExplanationAction(
    String explanationText,
  ) async {
    final rawText = _extractedBlock?['raw_source_text'] ?? '';

    if (rawText.isEmpty || explanationText.isEmpty) {
      throw '원문 텍스트 또는 해설 내용이 없습니다.';
    }

    _isReviewing = true;
    notifyListeners();

    try {
      final reviewData = await _repository.reviewQuizAlignment(rawText, [
        {'type': 'text', 'content': explanationText},
      ]);
      return reviewData;
    } catch (e) {
      throw e.toString();
    } finally {
      _isReviewing = false;
      notifyListeners();
    }
  }

  Future<void> saveToDb({
    required String questionText,
    required String explanationText,
    required List<String> hintTexts,
    required List<String> optionTexts,
  }) async {
    if (_extractedBlock == null) {
      throw '추출된 데이터가 없습니다.';
    }

    if (_initialSubject == null ||
        _initialYear == null ||
        _initialRound == null ||
        _selectedQuestion <= 0) {
      throw '필수 key 에러: (과목, 년도, 회차, 문제번호) 중 누락된 정보가 있습니다.';
    }

    _isSaving = true;
    notifyListeners();

    final data = {
      'raw_source_text': _extractedBlock!['raw_source_text'],
      'subject': _initialSubject,
      'year': _initialYear,
      'round': _initialRound,
      'question_number': _selectedQuestion,
      'content_blocks': [
        {'type': 'text', 'content': questionText},
      ],
      'explanation_blocks': [
        {'type': 'text', 'content': explanationText},
      ],
      'hint_blocks': hintTexts
          .take(_hintsCount)
          .map((text) => {'type': 'text', 'content': text})
          .toList(),
      'options': optionTexts
          .take(4) // 기출문제는 보통 4지선다
          .map((text) => {'type': 'text', 'content': text})
          .toList(),
      'correct_option_index': _correctOptionIndex,
      'difficulty': 1,
    };

    try {
      await _repository.upsertQuizQuestion(data);
    } catch (e) {
      throw e.toString();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // UI 호환성을 위한 래퍼 메서드들
  Future<void> saveCurrentQuizToDbAction({
    required String question,
    required String explanation,
    required List<String> options,
    required List<String> hints,
  }) => saveToDb(
    questionText: question,
    explanationText: explanation,
    optionTexts: options,
    hintTexts: hints,
  );

  Future<List<String>> generateOptionsAction(
    String question,
    String correctAnswer,
  ) => generateDistractorsAction(question, correctAnswer);

  Future<void> recommendSimilarAction(String question) =>
      recommendRelatedAction(question);

  Future<void> startBatchExtractionAction({
    required String fileId,
    required int singleQuestionNumber,
    required Function(int current, int total) onProgress,
    required Function(String message) onMessage,
  }) async {
    _selectedFileId = fileId;
    _selectedQuestion = singleQuestionNumber;
    _isLoading = true;
    _extractionProgress = 0.0;
    notifyListeners();

    try {
      await extractQuiz();
      populateExtractedQuiz();
      onProgress(1, 1);
      _extractionProgress = 1.0;
    } catch (e) {
      onMessage(e.toString());
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
