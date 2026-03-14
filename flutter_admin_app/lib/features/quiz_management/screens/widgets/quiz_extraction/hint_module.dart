import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/quiz_extraction_step2_viewmodel.dart';

class HintModule extends StatefulWidget {
  final TextEditingController questionController;
  final TextEditingController explanationController;
  final List<TextEditingController> hintControllers;

  const HintModule({
    super.key,
    required this.questionController,
    required this.explanationController,
    required this.hintControllers,
  });

  @override
  State<HintModule> createState() => _HintModuleState();
}

class _HintModuleState extends State<HintModule> {
  bool _isGenerating = false;

  Future<void> _generateHints() async {
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
      final hints = await vm.generateHintsAction(questionText, explanationText);
      if (mounted && hints.isNotEmpty) {
        for (int i = 0; i < widget.hintControllers.length; i++) {
          if (i < hints.length) {
            widget.hintControllers[i].text = hints[i];
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('힌트 생성 중 오류가 발생했습니다: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const aiColor = Color(0xFF2BEE8C);
    final vm = Provider.of<QuizExtractionStep2ViewModel>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '힌트 설정',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                DropdownButton<int>(
                  value: vm.hintsCount,
                  dropdownColor: const Color(0xFF161B22),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  underline: Container(),
                  items: [1, 2, 3].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value개'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) vm.setHintsCount(val);
                  },
                ),
                TextButton.icon(
                  onPressed: _isGenerating ? null : _generateHints,
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome, size: 16),
                  label: const Text('AI 힌트 생성'),
                  style: TextButton.styleFrom(foregroundColor: aiColor),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(vm.hintsCount, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: widget.hintControllers[index],
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: '힌트 ${index + 1}',
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
