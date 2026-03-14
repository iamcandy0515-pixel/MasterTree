import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_admin_app/features/quiz_management/repositories/quiz_repository.dart';
import 'package:flutter_admin_app/core/utils/snackbar_util.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_admin_app/core/widgets/fullscreen_image_viewer.dart';

class QuizReviewDetailScreen extends StatefulWidget {
  final int quizId;

  const QuizReviewDetailScreen({super.key, required this.quizId});

  @override
  State<QuizReviewDetailScreen> createState() => _QuizReviewDetailScreenState();
}

class _QuizReviewDetailScreenState extends State<QuizReviewDetailScreen> {
  static const primaryColor = Color(0xFF2BEE8C);
  static const backgroundDark = Color(0xFF102219);
  static const surfaceDark = Color(0xFF1A2E24);
  static const aiColor = Color(0xFF8B5CF6);

  final QuizRepository _repository = QuizRepository();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isReviewing = false;
  bool _isGenerating = false;
  bool _isRecommending = false;

  // 이미지 영역 확장 상태 (기본값 false: 축소)
  bool _isContentImagesExpanded = false;
  bool _isExpImagesExpanded = false;

  String _subject = '';
  String _year = '';
  String _round = '';
  String _questionNo = '';
  List<int> _selectedRelatedIds = [];
  List<Map<String, dynamic>> _relatedQuizzesMetadata = [];
  int _currentRelatedPage = 0;

  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _explanationController = TextEditingController();
  final TextEditingController _hintController = TextEditingController();

  List<dynamic> _contentBlocks = [];
  List<dynamic> _explanationBlocks = [];

  final List<TextEditingController> _incorrectOptionControllers = [];
  String _correctOption = '';
  int _correctOptionIndex = 0;

  final ImagePicker _picker = ImagePicker();

  final FocusNode _questionFocusNode = FocusNode();
  final FocusNode _explanationFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchQuizData();
    _questionFocusNode.addListener(() => setState(() {}));
    _explanationFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _questionFocusNode.dispose();
    _explanationFocusNode.dispose();
    _questionController.dispose();
    _explanationController.dispose();
    _hintController.dispose();
    for (var c in _incorrectOptionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchQuizData() async {
    try {
      final response = await Supabase.instance.client
          .from('quiz_questions')
          .select('*, quiz_exams(year, round), quiz_categories(name)')
          .eq('id', widget.quizId)
          .single();

      setState(() {
        final exam = response['quiz_exams'] as Map<String, dynamic>?;
        final category = response['quiz_categories'] as Map<String, dynamic>?;

        _subject = category?['name']?.toString() ?? '-';
        _year = exam?['year']?.toString() ?? '-';
        _round = exam?['round']?.toString() ?? '-';
        _questionNo =
            response['question_number']?.toString() ??
            response['id'].toString();

        _selectedRelatedIds =
            (response['related_quiz_ids'] as List<dynamic>?)
                ?.map((e) => int.parse(e.toString()))
                .toList() ??
            [];

        if (_selectedRelatedIds.isNotEmpty) {
          _loadRelatedQuizzesMetadata();
        }

        // Parse content
        _contentBlocks = response['content_blocks'] as List<dynamic>? ?? [];
        _questionController.text = _contentBlocks
            .map((block) {
              if (block is Map<String, dynamic> && block['type'] == 'text') {
                return block['content']?.toString() ?? '';
              } else if (block is String) {
                return block;
              }
              return '';
            })
            .where((text) => text.isNotEmpty)
            .join('\n');

        _explanationBlocks =
            response['explanation_blocks'] as List<dynamic>? ?? [];
        _explanationController.text = _explanationBlocks
            .map((block) {
              if (block is Map<String, dynamic> && block['type'] == 'text') {
                return block['content']?.toString() ?? '';
              } else if (block is String) {
                return block;
              }
              return '';
            })
            .where((text) => text.isNotEmpty)
            .join('\n');

        final hintBlocks = response['hint_blocks'] as List<dynamic>?;
        if (hintBlocks != null && hintBlocks.isNotEmpty) {
          _hintController.text = hintBlocks
              .map(
                (h) =>
                    h is Map ? (h['content']?.toString() ?? '') : h.toString(),
              )
              .join('\n');
        }

        final options = response['options'] as List<dynamic>? ?? [];
        _correctOptionIndex = response['correct_option_index'] ?? 0;

        _incorrectOptionControllers.clear();
        for (int i = 0; i < options.length; i++) {
          final content = options[i]['content'] ?? '';
          if (i == _correctOptionIndex) {
            _correctOption = content;
          } else {
            _incorrectOptionControllers.add(
              TextEditingController(text: content),
            );
          }
        }

        // Similar question stub (if exists in your DB, else empty)
        // Removed _similarQController.text

        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        SnackBarUtil.showFloating(context, '데이터 로딩 실패: $e', isError: true);
        Navigator.pop(context);
      }
    }
  }

  Future<void> _saveQuiz() async {
    setState(() => _isSaving = true);
    try {
      // Rebuild options list
      List<Map<String, dynamic>> newOptions = [];
      newOptions.add({
        'type': 'text',
        'content': _correctOption,
      }); // temporarily put correct at 0
      for (var c in _incorrectOptionControllers) {
        newOptions.add({'type': 'text', 'content': c.text});
      }
      // Re-shuffle or keep index 0 as correct for simplicity,
      final correctIndex =
          0; // We define index 0 as correct option in this UI approach

      // Update text in blocks
      final newContentBlocks = List.from(_contentBlocks);
      final contentText = _questionController.text;
      int firstContentTextIdx = newContentBlocks.indexWhere(
        (b) => b is String || (b is Map && b['type'] == 'text'),
      );
      if (firstContentTextIdx != -1) {
        newContentBlocks.removeWhere(
          (b) => b is String || (b is Map && b['type'] == 'text'),
        );
        newContentBlocks.insert(
          firstContentTextIdx.clamp(0, newContentBlocks.length),
          {'type': 'text', 'content': contentText},
        );
      } else {
        newContentBlocks.insert(0, {'type': 'text', 'content': contentText});
      }

      final newExpBlocks = List.from(_explanationBlocks);
      final explanationText = _explanationController.text;
      int firstExpTextIdx = newExpBlocks.indexWhere(
        (b) => b is String || (b is Map && b['type'] == 'text'),
      );
      if (firstExpTextIdx != -1) {
        newExpBlocks.removeWhere(
          (b) => b is String || (b is Map && b['type'] == 'text'),
        );
        newExpBlocks.insert(firstExpTextIdx.clamp(0, newExpBlocks.length), {
          'type': 'text',
          'content': explanationText,
        });
      } else {
        newExpBlocks.insert(0, {'type': 'text', 'content': explanationText});
      }

      final updateData = {
        'id': widget.quizId,
        'content_blocks': newContentBlocks,
        'explanation_blocks': newExpBlocks,
        'hint_blocks': [
          {'type': 'text', 'content': _hintController.text},
        ],
        'options': newOptions,
        'correct_option_index': correctIndex,
        'raw_source_text': '', // No longer using direct text field
        'status': 'published',
        'related_quiz_ids': _selectedRelatedIds,
      };

      await _repository.upsertQuizQuestion(updateData);

      if (mounted) {
        SnackBarUtil.showFloating(context, '성공적으로 저장되었습니다.');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtil.showFloating(context, '저장 실패: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _aiReview() async {
    final explanationText = _explanationController.text;
    final rawText = _relatedQuizzesMetadata.isNotEmpty
        ? (_relatedQuizzesMetadata.first['content_blocks'] as List?)
                  ?.where((b) => b['type'] == 'text')
                  .map((b) => b['content'])
                  .join('\n') ??
              ''
        : '';

    if (explanationText.isEmpty) {
      SnackBarUtil.showFloating(context, '해설 내용이 없습니다.', isError: true);
      return;
    }

    setState(() => _isReviewing = true);

    try {
      final reviewData = await _repository.reviewQuizAlignment(rawText, [
        {'type': 'text', 'content': explanationText},
      ]);
      final isAligned = reviewData['isAligned'] ?? false;
      final score = reviewData['confidenceScore'] ?? 0;
      final suggestions = reviewData['suggestedFixes'] ?? [];
      final reviewNotes = reviewData['reviewNotes'] ?? '';

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: surfaceDark,
              title: Row(
                children: [
                  Icon(
                    isAligned ? Icons.check_circle : Icons.warning,
                    color: isAligned ? primaryColor : Colors.orangeAccent,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      isAligned ? 'AI 검수 완료 (일치)' : 'AI 검수 완료 (불일치/이슈)',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '신뢰도 점수: $score / 100',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '검토 의견:\n$reviewNotes',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    if (suggestions.isNotEmpty && !isAligned) ...[
                      const SizedBox(height: 16),
                      Text(
                        '수정 제안:',
                        style: TextStyle(
                          color: Colors.orange[300],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(suggestions as List).map<Widget>(
                        (s) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            '- $s',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    '닫기',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
                if (!isAligned && suggestions.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      _explanationController.text = suggestions.first;
                      Navigator.pop(context);
                    },
                    child: const Text(
                      '첫번째 제안으로 교체',
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtil.showFloating(context, '검수 실패: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isReviewing = false);
      }
    }
  }

  Future<void> _loadRelatedQuizzesMetadata() async {
    try {
      final response = await Supabase.instance.client
          .from('quiz_questions')
          .select(
            'id, question_number, quiz_exams(year, round, title), quiz_categories(name), content_blocks',
          )
          .filter('id', 'in', _selectedRelatedIds);

      if (mounted) {
        setState(() {
          _relatedQuizzesMetadata = List<Map<String, dynamic>>.from(response);

          // 연도(year)와 회차(round) 내림차순(최신순) 정렬 적용
          _relatedQuizzesMetadata.sort((a, b) {
            final yearA = a['quiz_exams']?['year'] ?? 0;
            final yearB = b['quiz_exams']?['year'] ?? 0;
            if (yearA != yearB) {
              return yearB.compareTo(yearA);
            } else {
              final roundA = a['quiz_exams']?['round'] ?? 0;
              final roundB = b['quiz_exams']?['round'] ?? 0;
              return roundB.compareTo(roundA);
            }
          });

          // Sync selection list just in case some were deleted
          _selectedRelatedIds = _relatedQuizzesMetadata
              .map((e) => e['id'] as int)
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading related metadata: $e');
    }
  }

  Future<void> _generateDistractors() async {
    final questionText = _questionController.text;
    final correctAnswer = _correctOption;

    if (questionText.isEmpty || correctAnswer.isEmpty) {
      SnackBarUtil.showFloating(
        context,
        '문제와 정답 내용이 있어야 오답 생성이 가능합니다.',
        isError: true,
      );
      return;
    }

    setState(() => _isGenerating = true);
    SnackBarUtil.showFloating(context, 'AI가 매력적인 오답을 생성중입니다...');

    try {
      final distractors = await _repository.generateDistractors(
        questionText,
        correctAnswer,
      );

      setState(() {
        for (
          int i = 0;
          i < _incorrectOptionControllers.length && i < distractors.length;
          i++
        ) {
          _incorrectOptionControllers[i].text = distractors[i];
        }
      });
      if (mounted) {
        SnackBarUtil.showFloating(context, '오답 생성이 완료되었습니다.');
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtil.showFloating(context, '오답 생성 실패: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _recommendSimilar() async {
    final questionText = _questionController.text;

    if (questionText.isEmpty) {
      SnackBarUtil.showFloating(
        context,
        '문제가 있어야 연관 문제를 추천할 수 있습니다.',
        isError: true,
      );
      return;
    }

    setState(() => _isRecommending = true);
    SnackBarUtil.showFloating(context, 'AI가 연관 문제를 찾는 중입니다...');

    try {
      final relatedRaw = await _repository.recommendRelated(
        questionText: questionText,
        limit: 10,
      );
      // 자기 자신의 퀴즈는 제외 (ID 기준)
      final related = (relatedRaw)
          .where((r) => r['id'] != widget.quizId)
          .toList();

      // 연도(year)와 회차(round) 내림차순(최신순) 정렬 적용
      related.sort((a, b) {
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

      if (related.isNotEmpty && mounted) {
        _showSimilarQuizzesPopup(related);
      } else {
        if (mounted) {
          SnackBarUtil.showFloating(
            context,
            '추천할 만한 유사 문제가 없습니다.',
            isError: true,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtil.showFloating(context, '추천 실패: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isRecommending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        title: const Text('문제 상세내용'),
        backgroundColor: backgroundDark,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading || _isSaving ? null : _saveQuiz,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: primaryColor,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    '저장',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Key Properties
                  _buildInfoBanner(),
                  const SizedBox(height: 24),

                  // 2. Question
                  _buildSectionWithImages(
                    '문제',
                    _questionController,
                    _contentBlocks,
                    'content_blocks',
                  ),
                  const SizedBox(height: 24),

                  // 3. Answer & Explanation
                  _buildSectionWithImages(
                    '정답 및 해설',
                    _explanationController,
                    _explanationBlocks,
                    'explanation_blocks',
                    aiReviewAction: _aiReview,
                    isReviewing: _isReviewing,
                  ),
                  const SizedBox(height: 24),

                  // 4. Incorrect Options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle('오답'),
                      _isGenerating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: primaryColor,
                                strokeWidth: 2,
                              ),
                            )
                          : _buildAIAssistantButton(
                              '오답생성',
                              Icons.smart_toy,
                              _generateDistractors,
                            ),
                    ],
                  ),
                  ...List.generate(_incorrectOptionControllers.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _buildTextField(
                        _incorrectOptionControllers[index],
                        maxLines: 1,
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

                  // 5. Hint
                  _buildSectionTitle('힌트'),
                  _buildTextField(_hintController, maxLines: 2),
                  const SizedBox(height: 24),

                  // 6. Similar Question
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle('유사문제'),
                      _isRecommending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: primaryColor,
                                strokeWidth: 2,
                              ),
                            )
                          : _buildAIAssistantButton(
                              'AI 추천',
                              Icons.lightbulb,
                              _recommendSimilar,
                            ),
                    ],
                  ),
                  _buildRelatedQuizzesSection(),
                  // Removed old ID text display
                  const SizedBox(height: 48),
                  const SizedBox(height: 48),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(child: _buildInfoItem('과목', _subject)),
          _buildDivider(),
          Expanded(child: _buildInfoItem('년도', '$_year년')),
          _buildDivider(),
          Expanded(child: _buildInfoItem('회차', '$_round회')),
          _buildDivider(),
          Expanded(child: _buildInfoItem('문제번호', _questionNo)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 24, width: 1, color: Colors.white10);
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: primaryColor,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showSimilarQuizzesPopup(List<dynamic> related) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setPopupState) {
            return AlertDialog(
              backgroundColor: surfaceDark,
              title: const Text(
                'AI 유사문제 추천',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: related.length,
                  separatorBuilder: (_, __) =>
                      const Divider(color: Colors.white10),
                  itemBuilder: (context, index) {
                    final item = related[index];
                    final id = int.parse(item['id'].toString());
                    final isSelected = _selectedRelatedIds.contains(id);

                    return CheckboxListTile(
                      value: isSelected,
                      activeColor: primaryColor,
                      checkColor: backgroundDark,
                      onChanged: (val) {
                        setPopupState(() {
                          if (val == true) {
                            if (!_selectedRelatedIds.contains(id)) {
                              _selectedRelatedIds.add(id);
                            }
                          } else {
                            _selectedRelatedIds.remove(id);
                          }
                        });
                        setState(() {}); // Parent UI
                        _loadRelatedQuizzesMetadata(); // Reload metadata for cards
                      },
                      title: Text(
                        '${item['year'] ?? ''}년 ${item['round'] ?? ''}회 ${item['question_number'] ?? ''}번(${item['subject'] ?? ''})',
                        style: const TextStyle(
                          color: primaryColor,
                          fontSize: 12,
                        ),
                      ),
                      subtitle: Text(
                        (item['question'] ?? '내용 없음').toString().replaceAll(
                          RegExp(r'^\d+[\.\)]?\s*'),
                          '',
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    '확인',
                    style: TextStyle(color: primaryColor),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRelatedQuizzesSection() {
    if (_selectedRelatedIds.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: const Column(
          children: [
            Icon(Icons.lightbulb_outline, color: Colors.white24, size: 32),
            SizedBox(height: 8),
            Text(
              'AI 추천 버튼을 통해 유사 문제를 선택하세요',
              style: TextStyle(color: Colors.white24, fontSize: 13),
            ),
          ],
        ),
      );
    }

    const int itemsPerPage = 5;
    final int totalPages = (_relatedQuizzesMetadata.length / itemsPerPage)
        .ceil();

    // Check if the current page is out of bounds after a deletion
    if (_currentRelatedPage >= totalPages && totalPages > 0) {
      _currentRelatedPage = totalPages - 1;
    }

    final int startIndex = _currentRelatedPage * itemsPerPage;
    final int endIndex =
        (startIndex + itemsPerPage < _relatedQuizzesMetadata.length)
        ? startIndex + itemsPerPage
        : _relatedQuizzesMetadata.length;

    final visibleQuizzes = _relatedQuizzesMetadata.sublist(
      startIndex,
      endIndex,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_relatedQuizzesMetadata.length > itemsPerPage)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '유사 문제 목록 (${_relatedQuizzesMetadata.length}건)',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: _currentRelatedPage > 0
                          ? () => setState(() => _currentRelatedPage--)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_currentRelatedPage + 1} / $totalPages',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                      ),
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: _currentRelatedPage < totalPages - 1
                          ? () => setState(() => _currentRelatedPage++)
                          : null,
                    ),
                  ],
                ),
              ],
            )
          else
            Text(
              '유사 문제 목록 (${_relatedQuizzesMetadata.length}건)',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 12),

          ...visibleQuizzes.map((quiz) {
            final exam = quiz['quiz_exams'] as Map<String, dynamic>?;
            final year = exam?['year'] ?? '-';
            final round = exam?['round'] ?? '-';
            final qNo = quiz['question_number'] ?? '-';

            String content = '';
            final blocks = quiz['content_blocks'] as List?;
            if (blocks != null && blocks.isNotEmpty) {
              final textBlock = blocks.firstWhere(
                (b) => b is Map && b['type'] == 'text',
                orElse: () => {'content': ''},
              );
              if (textBlock != null) {
                content = textBlock['content']?.toString() ?? '';
              }
            }
            content = content.replaceAll('\n', ' ').trim();
            // 문제 지문 앞에 있는 문항 번호 패턴(예: '3.', '2)' 등) 제거
            content = content.replaceAll(RegExp(r'^\d+[\.\)]?\s*'), '');

            return Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 140, // Increased width
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$year년 $round회 $qNo번(${quiz['quiz_categories']?['name'] ?? '-'})',
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      content,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white38,
                      size: 16,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedRelatedIds.remove(quiz['id']);
                        _relatedQuizzesMetadata.removeWhere(
                          (m) => m['id'] == quiz['id'],
                        );
                      });
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    int maxLines = 1,
    FocusNode? focusNode,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor),
        ),
      ),
    );
  }

  Widget _buildSectionWithImages(
    String label,
    TextEditingController controller,
    List<dynamic> blocks,
    String blocksField, {
    VoidCallback? aiReviewAction,
    bool isReviewing = false,
  }) {
    final isContent = blocksField == 'content_blocks';
    final imageBlocks = blocks.where((b) => b['type'] == 'image').toList();
    final hasImages = imageBlocks.isNotEmpty;
    final isExpanded = isContent
        ? _isContentImagesExpanded
        : _isExpImagesExpanded;
    final focusNode = isContent ? _questionFocusNode : _explanationFocusNode;
    final isFocused = focusNode.hasFocus;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyV, control: true): () =>
            _handlePaste(blocksField),
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle(label),
              Row(
                children: [
                  if (hasImages)
                    IconButton(
                      icon: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.photo_library,
                        color: primaryColor.withValues(alpha: 0.8),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          if (isContent) {
                            _isContentImagesExpanded =
                                !_isContentImagesExpanded;
                          } else {
                            _isExpImagesExpanded = !_isExpImagesExpanded;
                          }
                        });
                      },
                      tooltip: isExpanded ? '이미지 접기' : '이미지 펼치기',
                    ),
                  if (aiReviewAction != null) ...[
                    isReviewing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: primaryColor,
                              strokeWidth: 2,
                            ),
                          )
                        : _buildAIAssistantButton(
                            'AI 검수',
                            Icons.auto_awesome,
                            aiReviewAction,
                          ),
                    const SizedBox(width: 8),
                  ],
                  IconButton(
                    icon: const Icon(
                      Icons.add_photo_alternate,
                      color: primaryColor,
                      size: 20,
                    ),
                    onPressed: () {
                      focusNode.requestFocus();
                      _pickAndUploadImage(blocksField);
                    },
                    tooltip: '이미지 추가',
                  ),
                ],
              ),
            ],
          ),
          // 1. Text Field First
          _buildTextField(controller, maxLines: 3, focusNode: focusNode),
          const SizedBox(height: 12),

          // 2. Paste Guide & Image List
          GestureDetector(
            onTap: () => focusNode.requestFocus(),
            child: Column(
              children: [
                // Always show guide (per Phase 2 requirement: "강제 노출")
                // Reduced padding if images exist to save space
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: hasImages ? 12 : 24),
                  decoration: BoxDecoration(
                    color: surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isFocused ? primaryColor : Colors.white10,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.content_paste_go,
                        color: isFocused ? primaryColor : Colors.white24,
                        size: hasImages ? 24 : 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '클립보드 이미지를 Ctrl+V로 붙여넣으세요',
                        style: TextStyle(
                          color: isFocused ? primaryColor : Colors.white54,
                          fontSize: hasImages ? 11 : 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Image List (if expanded)
                if (hasImages && isExpanded)
                  _buildVerticalImageListView(blocks, blocksField),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalImageListView(List<dynamic> blocks, String blocksField) {
    final imageEntries = blocks
        .asMap()
        .entries
        .where((e) => e.value['type'] == 'image')
        .toList();

    if (imageEntries.isEmpty) return const SizedBox.shrink();

    return Container(
      constraints: const BoxConstraints(maxHeight: 350), // 높이 제한 350px
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: imageEntries.length,
        itemBuilder: (context, index) {
          final entry = imageEntries[index];
          final blockIdx = entry.key;
          final url = entry.value['content'].toString();

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
              color: Colors.black26,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullscreenImageViewer(
                          imageUrl: url,
                          title:
                              '${blocksField == 'content_blocks' ? '문제' : '해설'} 이미지',
                        ),
                      ),
                    );
                  },
                  child: CachedNetworkImage(
                    imageUrl: url,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Container(
                      height: 150,
                      color: Colors.white10,
                      child: const Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 100,
                      color: Colors.white10,
                      child: const Icon(Icons.broken_image, color: Colors.red),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (blocksField == 'content_blocks') {
                          _contentBlocks.removeAt(blockIdx);
                        } else {
                          _explanationBlocks.removeAt(blockIdx);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handlePaste(String blocksField) async {
    // Disabled temporarily to fix build issues
    SnackBarUtil.showFloating(context, '붙여넣기 기능이 현재 비활성화되어 있습니다.', isError: true);
  }

  Future<void> _pickAndUploadImage(String blocksField) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    await _uploadImage(blocksField, image);
  }

  Future<void> _uploadImage(String blocksField, XFile image) async {
    final bytes = await image.readAsBytes();
    SnackBarUtil.showFloating(context, '이미지를 업로드 중입니다...');

    try {
      final url = await _repository.uploadQuizImage(bytes, image.name);
      setState(() {
        if (blocksField == 'content_blocks') {
          _contentBlocks.add({'type': 'image', 'content': url});
        } else {
          _explanationBlocks.add({'type': 'image', 'content': url});
        }
      });
      if (mounted) SnackBarUtil.showFloating(context, '이미지 업로드 완료');
    } catch (e) {
      if (mounted) {
        final errorLog = e.toString();
        String displayMsg = '업로드 실패';

        if (errorLog.contains('Exception:')) {
          displayMsg = errorLog.split('Exception:').last.trim();
        } else if (errorLog.contains('조정해서')) {
          displayMsg = errorLog;
        }

        SnackBarUtil.showFloating(context, '❌ $displayMsg', isError: true);
      }
    }
  }

  Widget _buildAIAssistantButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: aiColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: aiColor.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: aiColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: aiColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
