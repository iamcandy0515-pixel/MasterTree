import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/quiz_extraction_step2_viewmodel.dart';

class DistractorModule extends StatefulWidget {
  final TextEditingController questionController;
  final List<TextEditingController> optionControllers;

  const DistractorModule({
    super.key,
    required this.questionController,
    required this.optionControllers,
  });

  @override
  State<DistractorModule> createState() => _DistractorModuleState();
}

class _DistractorModuleState extends State<DistractorModule> {
  static const primaryColor = Color(0xFF2BEE8C);
  static const backgroundDark = Color(0xFF102219);

  Future<void> _generateDistractorsAction() async {
    final vm = context.read<QuizExtractionStep2ViewModel>();
    final questionText = widget.questionController.text;
    final correctAnswer = widget.optionControllers[0].text;

    if (questionText.isEmpty || correctAnswer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('문제와 현재 지정된 정답 내용을 확인해주세요.')),
      );
      return;
    }

    try {
      final distractors = await vm.generateDistractorsAction(
        questionText,
        correctAnswer,
      );
      if (mounted && distractors.isNotEmpty) {
        setState(() {
          int distIdx = 0;
          for (int i = 0; i < widget.optionControllers.length; i++) {
            if (i != 0 && distIdx < distractors.length) {
              // 0 is correct answer
              widget.optionControllers[i].text = distractors[distIdx];
              distIdx++;
            }
          }
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('오답이 성공적으로 재추천되었습니다.')));
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                '오답 (보기 구성)',
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
              onPressed: vm.extractedBlock == null
                  ? null
                  : _generateDistractorsAction,
              child: const Text(
                '오답 재추천',
                style: TextStyle(color: primaryColor, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundDark,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '정답',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: widget.optionControllers[0],
                maxLines: null,
                minLines: 1,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  hintText: '정답 원문',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundDark,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '오답',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: widget.optionControllers[1],
                maxLines: null,
                minLines: 1,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  hintText: '오답(매력적 보기)',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
