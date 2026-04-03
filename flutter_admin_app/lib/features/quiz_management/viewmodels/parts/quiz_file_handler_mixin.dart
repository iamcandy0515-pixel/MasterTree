import 'package:flutter/material.dart';
import '../../models/drive_file.dart';
import '../../repositories/quiz_drive_repository.dart';

mixin QuizFileHandlerMixin on ChangeNotifier {
  final QuizDriveRepository _repository = QuizDriveRepository();

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  bool _isValidating = false;
  bool get isValidating => _isValidating;

  bool _isExtractingInternal = false;
  bool get isExtractingInternal => _isExtractingInternal;

  bool? _searchSuccess;
  bool? get searchSuccess => _searchSuccess;

  String? _selectedFileId;
  String? get selectedFileId => _selectedFileId;

  List<DriveFile> _driveFiles = [];
  List<DriveFile> get driveFiles => _driveFiles;

  String? _extractedFilterRawString;
  String? get extractedFilterRawString => _extractedFilterRawString;

  Map<String, dynamic>? _validatedQuizData;
  Map<String, dynamic>? get validatedQuizData => _validatedQuizData;

  void setSelectedFileId(String id) {
    _selectedFileId = id;
    notifyListeners();
  }

  void setInitialFiles(List<DriveFile> files) {
    if (files.isNotEmpty) {
      _driveFiles = List<DriveFile>.from(files);
      _selectedFileId = files.first.id;
      notifyListeners();
    }
  }

  Future<void> searchFiles(String keyword) async {
    if (keyword.isEmpty) throw '검색할 키워드를 입력해주세요.';
    _isSearching = true;
    _searchSuccess = null;
    _driveFiles = [];
    _selectedFileId = null;
    notifyListeners();

    try {
      final List<Map<String, dynamic>> results = await _repository.searchDriveFiles(keyword);
      _driveFiles = results.map((e) => DriveFile.fromJson(e)).toList();
      if (_driveFiles.isNotEmpty) {
        _selectedFileId = _driveFiles.first.id;
        _searchSuccess = true;
      } else {
        _searchSuccess = false;
      }
    } catch (e) {
      _searchSuccess = false;
      debugPrint('❌ [SearchFiles] error: $e');
      throw e.toString();
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<void> validateFile(String? fallbackFileId, {String? subject, int? year, int? round}) async {
    String? targetFileId = _selectedFileId ?? fallbackFileId;
    if (targetFileId == null) throw '검증할 파일을 먼저 검색하거나 선택해주세요.';

    _isValidating = true;
    notifyListeners();

    try {
      final dynamic rawResult = await _repository.validateDriveFile(targetFileId, subject: subject, year: year, round: round);
      if (rawResult is! Map) throw '검증 응답 형식이 올바르지 않습니다.';
      
      final Map<String, dynamic> result = Map<String, dynamic>.from(rawResult);
      final dynamic rawValData = result['validation'];
      
      if (rawValData is Map) {
        final Map<String, dynamic> valData = Map<String, dynamic>.from(rawValData);
        final sbj = valData['extracted_subject']?.toString() ?? '';
        final yr = valData['extracted_year']?.toString() ?? '';
        final rd = valData['extracted_round']?.toString() ?? '';
        final filterParts = [sbj, yr, rd].where((e) => e.isNotEmpty).toList();
        _extractedFilterRawString = filterParts.isNotEmpty ? filterParts.join(', ') : null;

        if (!(valData['filter_matched'] ?? true)) {
          final String mismatchReason = valData['mismatch_reason']?.toString() ?? '';
          throw mismatchReason.isNotEmpty ? mismatchReason : 'AI 판독 결과 문제가 확인되지 않았습니다.';
        }
      } else {
        throw '검증에 실패했습니다. (잘못된 데이터 형식)';
      }
    } catch (e) {
      debugPrint('❌ [ValidateFile] error: $e');
      throw e.toString().contains('Failed to fetch') ? '서버 연결 실패 또는 시간 초과' : e.toString();
    } finally {
      _isValidating = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> extractQuizInternal(int questionNumber, int hintsCount) async {
    if (_selectedFileId == null) throw '파일을 검색하여 선택해주세요.';
    _isExtractingInternal = true;
    notifyListeners();
    try {
      final dynamic rawResult = await _repository.extractDriveFile(_selectedFileId!, questionNumber, hintsCount);
      if (rawResult is! Map) throw '추출 응답 형식이 올바르지 않습니다.';
      
      final Map<String, dynamic> result = Map<String, dynamic>.from(rawResult);
      final dynamic rawExtractedData = result['extractedData'];
      
      if (rawExtractedData is Map) {
        final Map<String, dynamic> extractedData = Map<String, dynamic>.from(rawExtractedData);
        if ((extractedData['error']?.toString().isNotEmpty ?? false)) throw extractedData['error'];

        final dynamic rawData = extractedData['data'];
        if (rawData is List && rawData.isNotEmpty) {
          _validatedQuizData = Map<String, dynamic>.from(rawData.first as Map);
          return _validatedQuizData!;
        } else {
          throw '해당 문제 번호가 존재하지 않거나 추출에 실패했습니다.';
        }
      }
      throw '추출 결과 데이터가 없습니다.';
    } catch (e) {
      debugPrint('❌ [ExtractQuizInternal] error: $e');
      throw e.toString().contains('Failed to fetch') ? '서버 연결 실패 또는 시간 초과' : e.toString();
    } finally {
      _isExtractingInternal = false;
      notifyListeners();
    }
  }
}
