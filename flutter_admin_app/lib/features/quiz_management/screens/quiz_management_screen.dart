import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_admin_app/features/quiz_management/repositories/quiz_repository.dart';
import 'quiz_review_detail_screen.dart';
import 'quiz_extraction_step2_screen.dart';

class QuizManagementScreen extends StatefulWidget {
  const QuizManagementScreen({super.key});

  @override
  State<QuizManagementScreen> createState() => _QuizManagementScreenState();
}

class _QuizManagementScreenState extends State<QuizManagementScreen> {
  final QuizRepository _quizRepo = QuizRepository();
  static const primaryColor = Color(0xFF2BEE8C);
  static const backgroundDark = Color(0xFF102219);
  static const surfaceDark = Color(0xFF1A2E24);

  String? _selectedSubject;
  String? _selectedYear;
  String? _selectedSession;

  final List<String> _subjects = [
    '산림기사',
    '산림산업기사',
    '산업안전기사',
    '산업안전산업기사',
    '조경기사',
    '조경산업기사',
  ];
  final List<String> _years = List.generate(
    14,
    (index) => (2013 + index).toString(),
  );
  final List<String> _sessions = ['1', '2', '3', '4'];

  bool _isLoading = false;
  List<Map<String, dynamic>> _quizzes = [];

  int _currentPage = 1;
  int _totalPages = 1;
  static const int _itemsPerPage = 5;

  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchQuizzes() async {
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final supabase = Supabase.instance.client;

      var baseQuery = supabase.from('quiz_questions').select('''
        *,
        quiz_exams!inner(year, round, title),
        quiz_categories!inner(name)
      ''');

      if (_selectedSubject != null) {
        baseQuery = baseQuery.like(
          'quiz_categories.name',
          '%${_selectedSubject!}%',
        );
      }
      if (_selectedYear != null) {
        baseQuery = baseQuery.eq('quiz_exams.year', int.parse(_selectedYear!));
      }
      if (_selectedSession != null) {
        baseQuery = baseQuery.eq(
          'quiz_exams.round',
          int.parse(_selectedSession!),
        );
      }

      final from = (_currentPage - 1) * _itemsPerPage;
      final to = from + _itemsPerPage - 1;

      final dataQuery = baseQuery
          .order('question_number', ascending: true)
          .range(from, to);
      final response = await dataQuery;

      // Count calculation
      var countQuery = supabase
          .from('quiz_questions')
          .select(
            'id, quiz_exams!inner(year, round), quiz_categories!inner(name)',
          );
      if (_selectedSubject != null) {
        countQuery = countQuery.like(
          'quiz_categories.name',
          '%${_selectedSubject!}%',
        );
      }
      if (_selectedYear != null) {
        countQuery = countQuery.eq(
          'quiz_exams.year',
          int.parse(_selectedYear!),
        );
      }
      if (_selectedSession != null) {
        countQuery = countQuery.eq(
          'quiz_exams.round',
          int.parse(_selectedSession!),
        );
      }

      final allIds = await countQuery;
      final totalItems = (allIds as List).length;

      setState(() {
        _quizzes = List<Map<String, dynamic>>.from(response);
        _totalPages = (totalItems / _itemsPerPage).ceil();
        if (_totalPages == 0) _totalPages = 1;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('데이터를 불러오는데 실패했습니다: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteQuiz(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: backgroundDark,
        title: const Text('삭제 확인', style: TextStyle(color: Colors.white)),
        content: const Text(
          '정말 삭제하시겠습니까?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('확인', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _quizRepo.deleteQuiz(id);

      _fetchQuizzes();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('삭제되었습니다.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('삭제 실패: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        backgroundColor: backgroundDark,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '기출문제 일람',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      if (_selectedSubject == null ||
                          _selectedYear == null ||
                          _selectedSession == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('조회 조건(과목명, 년도, 회차)을 모두 선택해주세요.'),
                          ),
                        );
                        return;
                      }
                      _currentPage = 1;
                      _fetchQuizzes();
                    },
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primaryColor,
                      ),
                    )
                  : const Text(
                      '조회',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white10, height: 1),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      '조회 조건',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildDropdown(
                      hint: '과목',
                      value: _selectedSubject,
                      items: _subjects,
                      onChanged: (val) =>
                          setState(() => _selectedSubject = val),
                    ),
                    _buildDropdown(
                      hint: '년도',
                      value: _selectedYear,
                      items: _years,
                      onChanged: (val) => setState(() => _selectedYear = val),
                    ),
                    _buildDropdown(
                      hint: '회차',
                      value: _selectedSession,
                      items: _sessions,
                      onChanged: (val) =>
                          setState(() => _selectedSession = val),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        if (_selectedSubject == null ||
                            _selectedYear == null ||
                            _selectedSession == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('조회 조건(과목명, 년도, 회차)을 모두 선택해주세요.'),
                            ),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuizExtractionStep2Screen(
                              selectedFiles: [],
                              initialSubject: _selectedSubject,
                              initialYear: _selectedYear != null
                                  ? int.tryParse(_selectedYear!)
                                  : null,
                              initialRound: _selectedSession != null
                                  ? int.tryParse(_selectedSession!)
                                  : null,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        '신규등록',
                        style: TextStyle(color: primaryColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!_isLoading && _hasSearched && _quizzes.isNotEmpty)
            _buildPagination(),
          Expanded(
            child: !_hasSearched
                ? Center(
                    child: Text(
                      '조회 조건을 선택하고 조회 버튼을 눌러주세요.',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  )
                : _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  )
                : _quizzes.isEmpty
                ? Center(
                    child: Text(
                      '조건에 맞는 기출문제가 없습니다.',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _quizzes.length,
                    itemBuilder: (context, index) {
                      return _buildQuizTextCard(_quizzes[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: false,
          dropdownColor: surfaceDark,
          hint: Text(
            hint,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          value: value,
          icon: const Icon(Icons.expand_more, color: primaryColor, size: 16),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
        ),
      ),
    );
  }

  String _extractQuestionText(Map<String, dynamic> quiz) {
    String qText = '문제 내용 없음';
    try {
      final blocks = quiz['content_blocks'];
      if (blocks != null && blocks is List && blocks.isNotEmpty) {
        // Handle various block structures (String content or Map with 'content')
        final firstBlock = blocks[0];
        if (firstBlock is String) {
          qText = firstBlock;
        } else if (firstBlock is Map && firstBlock.containsKey('content')) {
          qText = firstBlock['content'] as String;
        }

        // '1.' ~ '15.' 등 기출문제 본문 앞의 번호 패턴 제거
        // 숫자 앞의 공백, 숫자 뒤의 마침표(.) 또는 다중 공백을 모두 처리
        qText = qText.replaceFirst(RegExp(r'^\s*\d+[\.\s]+'), '').trim();
      }
    } catch (e) {
      debugPrint('Error extracting quiz text: $e');
    }

    final qNum = quiz['question_number'];
    if (qNum != null) {
      return '$qNum번. $qText';
    }
    return qText;
  }

  Widget _buildQuizTextCard(Map<String, dynamic> quiz) {
    final qText = _extractQuestionText(quiz);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuizReviewDetailScreen(quizId: quiz['id']),
              ),
            ).then((_) {
              // Re-fetch in case details changed
              _fetchQuizzes();
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    qText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.white54,
                    size: 20,
                  ),
                  onPressed: () => _deleteQuiz(quiz['id']),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page, color: Colors.white),
            onPressed: _currentPage > 1
                ? () {
                    setState(() {
                      _currentPage = 1;
                    });
                    _fetchQuizzes();
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: _currentPage > 1
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                    _fetchQuizzes();
                  }
                : null,
          ),
          const SizedBox(width: 16),
          Text(
            '$_currentPage / $_totalPages',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            onPressed: _currentPage < _totalPages
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                    _fetchQuizzes();
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.last_page, color: Colors.white),
            onPressed: _currentPage < _totalPages
                ? () {
                    setState(() {
                      _currentPage = _totalPages;
                    });
                    _fetchQuizzes();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
