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
  static const primaryColor = Color(0xFF2BEE8C);
  static const backgroundDark = Color(0xFF102219);
  static const borderDark = Color(0xFF253D33);

  Future<void> _generateHintsAction() async {
    final vm = context.read<QuizExtractionStep2ViewModel>();
    final questionText = widget.questionController.text;
    final explanation = widget.explanationController.text;

    if (questionText.isEmpty || explanation.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('문제와 해설 내용을 먼저 확인해주세요.')));
      return;
    }

    try {
      final hints = await vm.generateHintsAction(questionText, explanation);
      if (mounted) {
        setState(() {
          for (int i = 0; i < vm.hintsCount; i++) {
            if (i < hints.length) {
              widget.hintControllers[i].text = hints[i];
            }
          }
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('힌트가 성공적으로 재추천되었습니다.')));
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
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            Text(
              '제공될 힌트',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: backgroundDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderDark),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          if (vm.hintsCount > 1) {
                            vm.setHintsCount(vm.hintsCount - 1);
                          }
                        },
                        child: const Icon(
                          Icons.remove,
                          color: primaryColor,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${vm.hintsCount}개',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () {
                          if (vm.hintsCount < 5) {
                            vm.setHintsCount(vm.hintsCount + 1);
                          }
                        },
                        child: const Icon(
                          Icons.add,
                          color: primaryColor,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: vm.extractedBlock == null
                      ? null
                      : _generateHintsAction,
                  child: const Text(
                    '힌트 재추천',
                    style: TextStyle(color: primaryColor, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...List.generate(vm.hintsCount, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: borderDark,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: widget.hintControllers[index],
                    maxLines: null,
                    minLines: 1,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      filled: false,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 0,
                      ),
                      isDense: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
