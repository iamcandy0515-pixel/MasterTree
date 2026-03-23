import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/quiz_extraction_step2_viewmodel.dart';

class RelatedQuestionModule extends StatefulWidget {
  final TextEditingController questionController;

  const RelatedQuestionModule({super.key, required this.questionController});

  @override
  State<RelatedQuestionModule> createState() => _RelatedQuestionModuleState();
}

class _RelatedQuestionModuleState extends State<RelatedQuestionModule> {
  static const primaryColor = Color(0xFF2BEE8C);
  static const cardDark = Color(0xFF1A2E26);
  static const borderDark = Color(0xFF253D33);

  Future<void> _recommendRelatedAction() async {
    final vm = context.read<QuizExtractionStep2ViewModel>();
    final questionText = widget.questionController.text;

    if (questionText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('문제를 먼저 추출하거나 입력해주세요.')));
      return;
    }

    try {
      await vm.recommendRelatedAction(questionText);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('유사문제가 추천되었습니다.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<QuizExtractionStep2ViewModel>();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Text(
                '유사문제',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: vm.extractedBlock == null || vm.isRecommending
                  ? null
                  : _recommendRelatedAction,
              child: vm.isRecommending
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primaryColor,
                      ),
                    )
                  : const Text(
                      'AI 추천',
                      style: TextStyle(color: primaryColor, fontSize: 12),
                    ),
            ),
          ],
        ),
        if (vm.relatedQuestions.isNotEmpty)
          ...vm.relatedQuestions.map((related) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    related['source'] ?? '출처 없음',
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    related['question'] ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
