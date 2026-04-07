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
      _driveFiles = files;
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

  Future<void> validateFile(String? fallbackFileId, {String? subject, int? year, int? round}) async {
    String? targetFileId = _selectedFileId ?? fallbackFileId;
    if (targetFileId == null) throw '검증할 파일을 먼저 검색하거나 선택해주세요.';

    _isValidating = true;
    notifyListeners();

    try {
      final result = await _repository.validateDriveFile(targetFileId, subject: subject, year: year, round: round);
      final dynamic valData = result['validation'];

      if (valData is Map) {
        final sbj = valData['extracted_subject']?.toString() ?? '';
        final yr = valData['extracted_year']?.toString() ?? '';
        final rd = valData['extracted_round']?.toString() ?? '';
        final filterParts = [sbj, yr, rd].where((e) => e.isNotEmpty).toList();
        _extractedFilterRawString = filterParts.isNotEmpty ? filterParts.join(', ') : null;

        if (!((valData['filter_matched'] as bool?) ?? true)) {
          final String mismatchReason = valData['mismatch_reason']?.toString() ?? '';
          throw mismatchReason.isNotEmpty ? mismatchReason : 'AI 판독 결과 문제가 확인되지 않았습니다.';
        }
      } else {
        throw '검증에 실패했습니다. (잘못된 응답 데이터)';
      }
    } catch (e) {
      throw e.toString().contains('Failed to fetch') ? '백엔드 서버와 연결할 수 없거나 서버 응답 시간이 초과되었습니다.' : e.toString();
    } finally {
      _isValidating = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> extractQuizInternal(int questionNumber, int hintsCount) async {
    if (_selectedFileId == null) throw '파일을 먼저 검색하여 선택해주세요.';
    _isExtractingInternal = true;
    notifyListeners();
    try {
      final result = await _repository.extractDriveFile(_selectedFileId!, questionNumber, hintsCount);
      final dynamic extractedData = result['extractedData'];
      if (extractedData is Map && (extractedData['error']?.toString().isNotEmpty ?? false)) {
        throw extractedData['error'].toString();
      }

      final dataBlocks = extractedData['data'] as List?;
      if (dataBlocks != null && dataBlocks.isNotEmpty) {
        _validatedQuizData = (dataBlocks.first as Map<String, dynamic>?);
        return _validatedQuizData!;
      } else {
        throw '해당 문제 번호가 존재하지 않거나 추출에 실패했습니다.';
      }
    } catch (e) {
      throw e.toString().contains('Failed to fetch') ? '백엔드 서버와 연결할 수 없거나 서버 응답 시간이 초과되었습니다.' : e.toString();
    } finally {
      _isExtractingInternal = false;
      notifyListeners();
    }
  }
}
