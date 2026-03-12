import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_admin_app/features/quiz_management/repositories/quiz_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/similar_quiz_review_dialog.dart';

class BulkSimilarManagementScreen extends StatefulWidget {
  const BulkSimilarManagementScreen({super.key});

  @override
  State<BulkSimilarManagementScreen> createState() =>
      _BulkSimilarManagementScreenState();
}

class _BulkSimilarManagementScreenState
    extends State<BulkSimilarManagementScreen> {
  final QuizRepository _quizRepo = QuizRepository();
  static const primaryColor = Color(0xFF2BEE8C);
  static const backgroundDark = Color(0xFF102219);
  static const surfaceDark = Color(0xFF1A2E24);
  static const aiColor = Color(0xFF00D1FF);

  final List<String> _subjects = [
    '산림기사',
    '산림산업기사',
    '산업안전기사',
    '산업안전산업기사',
    '조경기사',
    '조경산업기사',
  ];
  final List<String> _years = List.generate(14, (i) => (2013 + i).toString());
  final List<String> _rounds = ['1', '2', '3', '4'];

  String? _selectedSubject;
  String? _selectedYear;
  String? _selectedRound;

  bool _isFetching = false;
  bool _isProcessing = false;
  String _statusMessage = '';
  int _currentPage = 1;
  static const int _itemsPerPage = 5;

  List<Map<String, dynamic>> _quizzes = [];
  Map<int, List<Map<String, dynamic>>> _tempRecommendations = {};

  // 현재 분석 상태 (0: 대기, 1: 분석중, 2: 완료, 3: 실패)
  final Map<int, int> _analysisStatus = {};

  @override
  void initState() {
    super.initState();
    _loadSavedFilters();
  }

  Future<void> _loadSavedFilters() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedSubject = prefs.getString('sim_filter_subject');
      _selectedYear = prefs.getString('sim_filter_year');
      _selectedRound = prefs.getString('sim_filter_round');
    });

    if (_selectedSubject != null &&
        _selectedYear != null &&
        _selectedRound != null) {
      _fetchQuizzes();
    }
  }

  Future<void> _saveFilters() async {
    final prefs = await SharedPreferences.getInstance();
    if (_selectedSubject != null) {
      await prefs.setString('sim_filter_subject', _selectedSubject!);
    }
    if (_selectedYear != null) {
      await prefs.setString('sim_filter_year', _selectedYear!);
    }
    if (_selectedRound != null) {
      await prefs.setString('sim_filter_round', _selectedRound!);
    }
  }

  Future<void> _fetchQuizzes() async {
    if (_selectedSubject == null ||
        _selectedYear == null ||
        _selectedRound == null) {
      _showSnackBar('필터를 모두 선택해주세요.');
      return;
    }

    setState(() {
      _isFetching = true;
      _quizzes = [];
      _tempRecommendations = {};
      _analysisStatus.clear();
      _currentPage = 1;
      _statusMessage = '문제를 불러오는 중...';
    });

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('quiz_questions')
          .select(
            '*, quiz_exams!inner(year, round), quiz_categories!inner(name)',
          )
          .eq('quiz_exams.year', int.parse(_selectedYear!))
          .eq('quiz_exams.round', int.parse(_selectedRound!))
          .like('quiz_categories.name', '%$_selectedSubject%')
          .order('question_number', ascending: true);

      setState(() {
        _quizzes = List<Map<String, dynamic>>.from(response);
        for (var q in _quizzes) {
          final relatedIds = q['related_quiz_ids'] as List?;
          if (relatedIds != null && relatedIds.isNotEmpty) {
            _analysisStatus[q['id'] as int] = 2;
          } else {
            _analysisStatus[q['id'] as int] = 0;
          }
        }
        _statusMessage = '조회 완료: ${_quizzes.length}건';
      });
    } catch (e) {
      _showSnackBar('조회 실패: $e');
    } finally {
      setState(() => _isFetching = false);
    }
  }

  void _showReviewDialog(Map<String, dynamic> quiz) {
    showDialog(
      context: context,
      builder: (context) {
        return SimilarQuizReviewDialog(
          quiz: quiz,
          selectedYear: _selectedYear,
          selectedRound: _selectedRound,
          initialRecommendations: _tempRecommendations[quiz['id']] ?? [],
          quizRepo: _quizRepo,
          onUpdate: (updatedRecommendations) {
            setState(() {
              _tempRecommendations[quiz['id'] as int] = updatedRecommendations;
              if (updatedRecommendations.isNotEmpty) {
                _analysisStatus[quiz['id'] as int] = 2;
              } else {
                _analysisStatus[quiz['id'] as int] = 0;
              }
            });
          },
        );
      },
    );
  }

  Future<void> _runBulkRecommendation() async {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = min(startIndex + _itemsPerPage, _quizzes.length);
    final pageQuizzes = _quizzes.sublist(startIndex, endIndex);

    if (pageQuizzes.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = '현재 페이지 (5개) 분석을 시작합니다...';
    });

    for (var quiz in pageQuizzes) {
      final quizId = quiz['id'] as int;
      setState(() => _analysisStatus[quizId] = 1);

      final qText = _getFullQuizText(quiz);

      if (qText.isNotEmpty) {
        try {
          final result = await _quizRepo.recommendRelated(
            questionText: qText,
            limit: 10,
          );

          final filteredResult = (result)
              .where((r) => r['id'] != quizId)
              .toList();

          filteredResult.sort((a, b) {
            final yearA = a['year'] ?? 0;
            final yearB = b['year'] ?? 0;
            if (yearA != yearB) {
              return yearB.compareTo(yearA);
            } else {
              final roundA = a['round'] ?? 0;
              final roundB = b['round'] ?? 0;
              return roundB.compareTo(roundA);
            }
          });

          setState(() {
            _tempRecommendations[quizId] = List<Map<String, dynamic>>.from(
              filteredResult,
            );
            _analysisStatus[quizId] = 2;
          });
        } catch (e) {
          debugPrint('Error for ID $quizId: $e');
          setState(() => _analysisStatus[quizId] = 3);
        }
      } else {
        setState(() => _analysisStatus[quizId] = 3);
      }
      await Future.delayed(const Duration(milliseconds: 300));
    }

    setState(() {
      _isProcessing = false;
      _statusMessage = '현재 페이지 분석이 완료되었습니다.';
    });
  }

  Future<void> _saveAll() async {
    if (_tempRecommendations.isEmpty) return;

    setState(() => _isProcessing = true);
    _statusMessage = '유사 문제를 일괄 저장 중...';

    try {
      final relatedMap = _tempRecommendations.map((key, value) {
        return MapEntry(key, value.map((v) => v['id'] as int).toList());
      });

      await _quizRepo.upsertRelatedBulk(relatedMap);

      _showSnackBar('성공적으로 저장되었습니다.');
      setState(() {
        _tempRecommendations = {};
        _statusMessage = '저장 완료';
      });
      _fetchQuizzes();
    } catch (e) {
      _showSnackBar('저장 실패: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        backgroundColor: backgroundDark,
        title: const Text(
          '기출 유사문제 추출 (5개씩)',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          _buildTopActionButtons(),
          _buildFilterArea(),
          if (_quizzes.isNotEmpty) _buildPagination(),
          Expanded(child: _buildQuizList()),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    final totalPages = (_quizzes.length / _itemsPerPage).ceil();
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPageBtn('맨처음', 1),
          _buildPageBtn('이전', max(1, _currentPage - 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '$_currentPage / $totalPages',
              style: const TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildPageBtn('다음', min(totalPages, _currentPage + 1)),
          _buildPageBtn('맨끝', totalPages),
        ],
      ),
    );
  }

  Widget _buildPageBtn(String label, int page) {
    return TextButton(
      onPressed: _currentPage == page
          ? null
          : () => setState(() => _currentPage = page),
      child: Text(
        label,
        style: TextStyle(
          color: _currentPage == page ? Colors.white24 : primaryColor,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildFilterArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDropDown('과목', _selectedSubject, _subjects, (v) {
                  setState(() => _selectedSubject = v);
                  _saveFilters();
                  if (_selectedSubject != null && _selectedYear != null && _selectedRound != null) {
                    _fetchQuizzes();
                  }
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDropDown('년도', _selectedYear, _years, (v) {
                  setState(() => _selectedYear = v);
                  _saveFilters();
                  if (_selectedSubject != null && _selectedYear != null && _selectedRound != null) {
                    _fetchQuizzes();
                  }
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDropDown('회차', _selectedRound, _rounds, (v) {
                  setState(() => _selectedRound = v);
                  _saveFilters();
                  if (_selectedSubject != null && _selectedYear != null && _selectedRound != null) {
                    _fetchQuizzes();
                  }
                }),
              ),
            ],
          ),
          if (_statusMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _statusMessage,
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuizList() {
    if (_quizzes.isEmpty && !_isFetching) {
      return const Center(
        child: Text('조회된 문제가 없습니다.', style: TextStyle(color: Colors.grey)),
      );
    }
    if (_isFetching) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = min(startIndex + _itemsPerPage, _quizzes.length);
    final pageQuizzes = _quizzes.sublist(startIndex, endIndex);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      itemCount: pageQuizzes.length,
      itemBuilder: (context, index) {
        final quiz = pageQuizzes[index];
        final id = quiz['id'] as int;
        final status = _analysisStatus[id] ?? 0;
        final recs = _tempRecommendations[id] ?? [];
        final storedCount = (quiz['related_quiz_ids'] as List?)?.length ?? 0;
        final displayCount = max(recs.length, storedCount);

        return Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white10)),
          ),
          child: ListTile(
            onTap: () => _showReviewDialog(quiz),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Row(
              children: [
                Text(
                  'Q${quiz['question_number']}',
                  style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getFullQuizText(quiz).replaceAll(RegExp(r'^\d+[\.\)]?\s*'), ''),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusIcon(status, displayCount),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(int status, int recCount) {
    if (status == 1) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: aiColor),
      );
    }
    if (status == 2) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: primaryColor, size: 16),
          const SizedBox(width: 4),
          Text(
            '$recCount',
            style: const TextStyle(color: primaryColor, fontSize: 11),
          ),
        ],
      );
    }
    if (status == 3) {
      return const Icon(Icons.error_outline, color: Colors.redAccent, size: 16);
    }
    return const Icon(Icons.hourglass_empty, color: Colors.white24, size: 16);
  }

  Widget _buildTopActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: _isProcessing || _quizzes.isEmpty ? null : _runBulkRecommendation,
            icon: const Icon(Icons.flash_on, size: 18),
            label: const Text('일괄 유사문제 추출(page단위)'),
            style: TextButton.styleFrom(foregroundColor: primaryColor),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: _isProcessing || _tempRecommendations.isEmpty ? null : _saveAll,
            icon: const Icon(Icons.save, size: 18),
            label: const Text('일괄 저장'),
            style: TextButton.styleFrom(foregroundColor: primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildDropDown(String hint, String? value, List<String> items, Function(String?) onChanged) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: backgroundDark, borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(hint, style: const TextStyle(color: Colors.white24, fontSize: 13)),
          dropdownColor: surfaceDark,
          icon: const Icon(Icons.arrow_drop_down, color: primaryColor),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  String _getFullQuizText(Map<String, dynamic> quiz) {
    final blocks = quiz['content_blocks'] as List?;
    if (blocks == null || blocks.isEmpty) return '';
    return blocks.map((block) {
      if (block is Map<String, dynamic> && block['type'] == 'text') return block['content']?.toString() ?? '';
      if (block is String) return block.toString();
      return '';
    }).where((text) => text.isNotEmpty).join('\n').trim();
  }
}
