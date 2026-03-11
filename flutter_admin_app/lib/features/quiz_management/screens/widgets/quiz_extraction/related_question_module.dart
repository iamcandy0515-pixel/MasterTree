import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/quiz_extraction_step2_viewmodel.dart';

class RelatedQuestionModule extends StatefulWidget {
  final TextEditingController questionController;

  const RelatedQuestionModule({
    super.key,
    required this.questionController,
  });

  @override
  State<RelatedQuestionModule> createState() => _RelatedQuestionModuleState();
}

class _RelatedQuestionModuleState extends State<RelatedQuestionModule> {
  bool _isRecommending = false;

  Future<void> _recommendSimilar() async {
    final questionText = widget.questionController.text;
    if (questionText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('문제를 먼저 입력해주세요.')),
      );
      return;
    }

    final vm = context.read<QuizExtractionStep2ViewModel>();
    setState(() => _isRecommending = true);

    try {
      await vm.recommendSimilarAction(questionText);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('유사 문제가 추천되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('추천 중 오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRecommending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<QuizExtractionStep2ViewModel>(context);
    const aiColor = Color(0xFF8B5CF6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '유사 기출문제 추천',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: _isRecommending ? null : _recommendSimilar,
              icon: _isRecommending
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(aiColor)),
                    )
                  : const Icon(Icons.hub_outlined, size: 16),
              label: const Text('AI 유사문제 분석'),
              style: TextButton.styleFrom(foregroundColor: aiColor),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (vm.relatedQuizzes.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: vm.relatedQuizzes.length,
              itemBuilder: (context, index) {
                final quiz = vm.relatedQuizzes[index];
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: aiColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: aiColor.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${quiz['year'] ?? ''}년 회',
                        style: const TextStyle(color: aiColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        quiz['question_text'] ?? '',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: const Center(
              child: Text(
                '분석된 유사 문제가 없습니다.',
                style: TextStyle(color: Colors.white24, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }
}
