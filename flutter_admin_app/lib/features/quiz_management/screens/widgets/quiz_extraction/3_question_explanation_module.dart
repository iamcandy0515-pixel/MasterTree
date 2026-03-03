import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/quiz_extraction_step2_viewmodel.dart';
import 'package:flutter_admin_app/core/utils/snackbar_util.dart';

class QuestionAndExplanationModule extends StatefulWidget {
  final TextEditingController questionController;
  final TextEditingController explanationController;

  const QuestionAndExplanationModule({
    super.key,
    required this.questionController,
    required this.explanationController,
  });

  @override
  State<QuestionAndExplanationModule> createState() =>
      _QuestionAndExplanationModuleState();
}

class _QuestionAndExplanationModuleState
    extends State<QuestionAndExplanationModule> {
  static const primaryColor = Color(0xFF2BEE8C);
  static const cardDark = Color(0xFF1A2E26);

  Future<void> _reviewExplanationAction() async {
    final vm = context.read<QuizExtractionStep2ViewModel>();
    final explanationText = widget.explanationController.text;

    try {
      final reviewData = await vm.reviewExplanationAction(explanationText);
      final isAligned = reviewData['isAligned'] ?? false;
      final score = reviewData['confidenceScore'] ?? 0;
      final suggestions = reviewData['suggestedFixes'] ?? [];
      final reviewNotes = reviewData['reviewNotes'] ?? '';

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: cardDark,
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
                      ...suggestions.map<Widget>(
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
                      widget.explanationController.text = suggestions.first;
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
        SnackBarUtil.showFloating(context, e.toString(), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<QuizExtractionStep2ViewModel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '문제',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (vm.extractedFilterRawString != null) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '(AI 판별: ${vm.extractedFilterRawString})',
                  style: const TextStyle(color: primaryColor, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: widget.questionController,
          maxLines: null,
          minLines: 3,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: false,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 0,
            ),
            isDense: true,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintText: '문제 내용이 여기에 표시됩니다.',
            hintStyle: TextStyle(color: Colors.grey[600]),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                '정답 및 해설',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: vm.extractedBlock == null || vm.isReviewing
                  ? null
                  : _reviewExplanationAction,
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: vm.isReviewing
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primaryColor,
                      ),
                    )
                  : const Text(
                      'AI 검수',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: widget.explanationController,
          maxLines: null,
          minLines: 3,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: false,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 0,
            ),
            isDense: true,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintText: '정답 및 해설이 여기에 표시됩니다.',
            hintStyle: TextStyle(color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }
}
