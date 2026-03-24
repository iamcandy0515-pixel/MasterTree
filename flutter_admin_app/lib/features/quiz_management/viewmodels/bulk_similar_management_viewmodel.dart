// ignore_for_file: prefer_final_fields
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/quiz_repository.dart';
import '../repositories/quiz_ai_repository.dart';

part 'parts/bulk_filter_logic.part.dart';
part 'parts/bulk_action_logic.part.dart';

/// Bulk Similar Management ViewModel (Refactored Strategy: Modularization & Partial Logic)
/// 202라인 -> 70라인 이하로 최적화. 200줄 제한(1-1) 준수.
class BulkSimilarManagementViewModel extends ChangeNotifier {
  final QuizRepository _quizRepo = QuizRepository();
  final QuizAiRepository _aiRepo = QuizAiRepository();
  
  List<Map<String, dynamic>> _quizzes = [];
  Map<int, List<Map<String, dynamic>>> _tempRecommendations = {};
  final Map<int, int> _analysisStatus = {}; // 0:대기, 1:분석중, 2:완료, 3:실패
  String? _selectedSubject, _selectedYear, _selectedRound;
  bool _isFetching = false, _isProcessing = false;
  String _statusMessage = '';
  int _currentPage = 1;
  static const int itemsPerPage = 5;

  // Getters
  List<Map<String, dynamic>> get quizzes => _quizzes;
  Map<int, List<Map<String, dynamic>>> get tempRecommendations => _tempRecommendations;
  Map<int, int> get analysisStatus => _analysisStatus;
  String? get selectedSubject => _selectedSubject;
  String? get selectedYear => _selectedYear;
  String? get selectedRound => _selectedRound;
  bool get isFetching => _isFetching;
  bool get isProcessing => _isProcessing;
  String get statusMessage => _statusMessage;
  int get currentPage => _currentPage;
  int get totalPages => (_quizzes.length / itemsPerPage).ceil();

  final List<String> subjects = ['산림기사', '산림산업기사', '산업안전기사', '산업안전산업기사', '조경기사', '조경산업기사'];
  final List<String> years = List.generate(14, (i) => (2013 + i).toString());
  final List<String> rounds = ['1', '2', '3', '4'];

  /// 현재 페이지의 퀴즈 리스트를 반환함 (Strategy: UI 계산 비용 ViewModel 이관)
  List<Map<String, dynamic>> getCurrentPageQuizzes() {
    final startIndex = (_currentPage - 1) * itemsPerPage;
    final int endIndex = (startIndex + itemsPerPage < _quizzes.length) 
        ? startIndex + itemsPerPage 
        : _quizzes.length;
    if (startIndex >= _quizzes.length) return [];
    return _quizzes.sublist(startIndex, endIndex);
  }
}
