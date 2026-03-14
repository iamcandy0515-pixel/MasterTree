import 'package:flutter/material.dart';
import 'package:flutter_user_app/core/design_system.dart';
import 'package:flutter_user_app/controllers/past_exam_detail_controller.dart';
import 'package:flutter_user_app/core/api_service.dart';
import 'package:flutter_user_app/screens/user_stats_screen.dart';
import 'package:flutter_user_app/core/widgets/content_block_renderer.dart';

class PastExamDetailScreen extends StatefulWidget {
  final int quizId;

  const PastExamDetailScreen({super.key, required this.quizId});

  @override
  State<PastExamDetailScreen> createState() => _PastExamDetailScreenState();
}

class _PastExamDetailScreenState extends State<PastExamDetailScreen> {
  final PastExamDetailController _controller = PastExamDetailController();

  // 이미지 영역 확장 상태 (기본값 false: 축소)
  bool _isQuestionExpanded = false;
  bool _isExplanationExpanded = false;

  @override
  void dispose() {
    // 화면 이탈 시 남은 학습 결과 동기화
    ApiService.syncPendingAttempts();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller.fetchQuizData(
      quizId: widget.quizId,
      onUpdate: () => setState(() {}),
      onError: (message) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('데이터 로딩 실패: $message')));
          Navigator.pop(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // 뒤로가기 시 보류 중인 결과 동기화 시도
        await ApiService.syncPendingAttempts();
        if (context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          title: const Text('기출 / 학습 상세'),
          backgroundColor: AppColors.backgroundDark,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () async {
              // 뒤로가기 시에도 동기화 트리거
              await ApiService.syncPendingAttempts();
              if (mounted) Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await ApiService.syncPendingAttempts();
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const UserStatsScreen(initialIndex: 2),
                    ),
                  );
                }
              },
              child: const Text(
                '학습통계',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        body: _controller.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoBanner(),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle('문제'),
                        if (_controller.contentBlocks.any(
                          (b) => b['type'] == 'image',
                        ))
                          IconButton(
                            icon: Icon(
                              _isQuestionExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.photo_library,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            onPressed: () => setState(
                              () => _isQuestionExpanded = !_isQuestionExpanded,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: _isQuestionExpanded ? '이미지 접기' : '이미지 펼치기',
                          ),
                      ],
                    ),
                    ContentBlockRenderer(
                      blocks: _controller.contentBlocks,
                      hideImages: !_isQuestionExpanded,
                    ),
                    const SizedBox(height: 12),

                    _buildSectionTitle(
                      '보기',
                      subtitle: '반드시 보기를 선택 해야만 해설을 볼수 있습니다',
                    ),
                    _buildOptionsList(),
                    const SizedBox(height: 12),

                    if (_controller.isAnswered &&
                        _controller.explanationBlocks.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionTitle('해설'),
                          if (_controller.explanationBlocks.any(
                            (b) => b['type'] == 'image',
                          ))
                            IconButton(
                              icon: Icon(
                                _isExplanationExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.photo_library,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _isExplanationExpanded =
                                    !_isExplanationExpanded,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: _isExplanationExpanded
                                  ? '이미지 접기'
                                  : '이미지 펼치기',
                            ),
                        ],
                      ),
                      ContentBlockRenderer(
                        blocks: _controller.explanationBlocks,
                        isHighlight: true,
                        hideImages: !_isExplanationExpanded,
                      ),
                      const SizedBox(height: 12),
                    ],

                    if (_controller.hintText.isNotEmpty) ...[
                      _buildSectionTitle('힌트'),
                      _buildDisplayBox(_controller.hintText),
                      const SizedBox(height: 12),
                    ],

                    // 유사문제 섹션
                    _buildRelatedQuizzesSection(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(child: _buildInfoItem('과목', _controller.subject)),
          _buildDivider(),
          Expanded(child: _buildInfoItem('년도', '${_controller.year}년')),
          _buildDivider(),
          Expanded(child: _buildInfoItem('회차', '${_controller.round}회')),
          _buildDivider(),
          Expanded(child: _buildInfoItem('번호', _controller.questionNo)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 20, width: 1, color: Colors.white10);
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDisplayBox(
    String text, {
    bool isHighlight = false,
    bool isItalic = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4),
      // 배경과 테두 제거
      decoration: null,
      child: Text(
        text,
        style: TextStyle(
          color: isHighlight
              ? AppColors.primary
              : Colors.white.withValues(alpha: 0.85),
          fontSize: 14,
          height: 1.4,
          fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
        ),
      ),
    );
  }

  Widget _buildOptionsList() {
    return Column(
      children: List.generate(_controller.options.length, (index) {
        final isCorrect = index == _controller.correctOptionIndex;
        final isSelected = index == _controller.selectedOptionIndex;
        final isAnswered = _controller.isAnswered;

        Color bgColor = Colors.transparent;
        Color textColor = Colors.white70;
        FontWeight fontWeight = FontWeight.normal;

        if (isAnswered) {
          if (isCorrect) {
            bgColor = AppColors.primary.withValues(alpha: 0.12);
            textColor = AppColors.primary;
            fontWeight = FontWeight.bold;
          } else if (isSelected) {
            bgColor = Colors.red.withValues(alpha: 0.12);
            textColor = Colors.redAccent;
            fontWeight = FontWeight.bold;
          }
        }

        return GestureDetector(
          onTap: () =>
              _controller.selectOption(index, onUpdate: () => setState(() {})),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              border: isAnswered && isSelected && !isCorrect
                  ? Border.all(color: Colors.redAccent.withValues(alpha: 0.3))
                  : (isAnswered && isCorrect
                        ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
                        : null),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${index + 1}. ',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: fontWeight,
                    fontSize: 14,
                  ),
                ),
                Expanded(
                  child: Text(
                    _controller.options[index],
                    style: TextStyle(
                      color: textColor,
                      fontWeight: fontWeight,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (isAnswered && isCorrect)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 16,
                  ),
                if (isAnswered && isSelected && !isCorrect)
                  const Icon(Icons.cancel, color: Colors.redAccent, size: 16),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRelatedQuizzesSection() {
    if (_controller.similarQuizzes.isEmpty) {
      return _buildSectionTitle('유사문제', subtitle: '검색된 유사문제가 없습니다.');
    }

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: const Text(
          '유사문제',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '이 문제와 유사한 ${_controller.similarQuizzes.length}개의 문제가 있습니다.',
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 10,
            fontStyle: FontStyle.italic,
          ),
        ),
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 12),
        children: _controller.similarQuizzes.map((quiz) {
          return _buildRelatedQuizCard(quiz);
        }).toList(),
      ),
    );
  }

  Widget _buildRelatedQuizCard(Map<String, dynamic> quiz) {
    final exam = quiz['quiz_exams'] as Map<String, dynamic>?;
    final year = exam?['year'] ?? '-';
    final round = exam?['round'] ?? '-';
    final qNo = quiz['question_number'] ?? '-';
    final subject = quiz['quiz_categories']?['name'] ?? '-';

    final blocks = quiz['content_blocks'] as List<dynamic>?;
    String qText = '내용 없음';
    if (blocks != null && blocks.isNotEmpty) {
      final textBlock = blocks.firstWhere(
        (b) => b['type'] == 'text',
        orElse: () => {'content': ''},
      );
      qText = textBlock['content']?.toString() ?? '내용 없음';
    }
    qText = qText.replaceAll('\n', ' ').trim();
    qText = qText.replaceAll(RegExp(r'^\d+[\.\)]?\s*'), '');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 140, // Increased to fit the format
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$year년 $round회 $qNo번($subject)',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              qText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
