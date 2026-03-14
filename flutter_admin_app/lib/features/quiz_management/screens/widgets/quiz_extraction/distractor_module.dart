import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/quiz_extraction_step2_viewmodel.dart';

class DistractorModule extends StatefulWidget {
  final TextEditingController questionController;
  final TextEditingController explanationController;
  final List<TextEditingController> optionControllers;

  const DistractorModule({
    super.key,
    required this.questionController,
    required this.explanationController,
    required this.optionControllers,
  });

  @override
  State<DistractorModule> createState() => _DistractorModuleState();
}

class _DistractorModuleState extends State<DistractorModule> {
  bool _isGenerating = false;

  Future<void> _generateOptions() async {
    final vm = context.read<QuizExtractionStep2ViewModel>();
    final questionText = widget.questionController.text;
    final explanationText = widget.explanationController.text;

    if (questionText.isEmpty || explanationText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('문제와 해설을 먼저 입력해주세요.')));
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final options = await vm.generateOptionsAction(
        questionText,
        explanationText,
      );
      if (mounted && options.isNotEmpty) {
        for (int i = 0; i < widget.optionControllers.length; i++) {
          if (i < options.length) {
            widget.optionControllers[i].text = options[i];
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('보기 생성 중 오류가 발생했습니다: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2BEE8C);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '정답 및 보기 설정',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: _isGenerating ? null : _generateOptions,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.psychology_alt, size: 16),
              label: const Text('AI 보기 생성'),
              style: TextButton.styleFrom(foregroundColor: primaryColor),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(widget.optionControllers.length, (index) {
          final bool isCorrect = index == 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: widget.optionControllers[index],
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: isCorrect ? '정답' : '보기 ${index + 1}',
                labelStyle: TextStyle(
                  color: isCorrect ? primaryColor : Colors.white54,
                  fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: isCorrect
                      ? BorderSide(color: primaryColor.withValues(alpha: 0.3))
                      : BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: primaryColor),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
