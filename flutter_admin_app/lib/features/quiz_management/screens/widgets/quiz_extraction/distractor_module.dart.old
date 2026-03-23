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
      ).showSnackBar(const SnackBar(content: Text('臾몄젣? ?댁꽕??癒쇱? ?낅젰?댁＜?몄슂.')));
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
        ).showSnackBar(SnackBar(content: Text('蹂닿린 ?앹꽦 以??ㅻ쪟媛 諛쒖깮?덉뒿?덈떎: $e')));
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
              '?뺣떟 諛?蹂닿린 ?ㅼ젙',
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
              label: const Text('AI 蹂닿린 ?앹꽦'),
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
                labelText: isCorrect ? '?뺣떟' : '蹂닿린 ${index + 1}',
                labelStyle: TextStyle(
                  color: isCorrect ? primaryColor : Colors.white54,
                  fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: isCorrect
                      ? BorderSide(color: primaryColor.withOpacity(0.3))
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

