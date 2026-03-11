import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/quiz_extraction_step2_viewmodel.dart';

class DbRegistrationModule extends StatefulWidget {
  final TextEditingController questionController;
  final TextEditingController explanationController;
  final List<TextEditingController> optionControllers;
  final List<TextEditingController> hintControllers;

  const DbRegistrationModule({
    super.key,
    required this.questionController,
    required this.explanationController,
    required this.optionControllers,
    required this.hintControllers,
  });

  @override
  State<DbRegistrationModule> createState() => _DbRegistrationModuleState();
}

class _DbRegistrationModuleState extends State<DbRegistrationModule> {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<QuizExtractionStep2ViewModel>(context);
    const primaryColor = Color(0xFF2BEE8C);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '최종 데이터베이스 등록',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: vm.isSaving ? null : () async {
            if (widget.questionController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('문제를 입력해주세요.')),
              );
              return;
            }
            await vm.saveCurrentQuizToDbAction(
              question: widget.questionController.text,
              explanation: widget.explanationController.text,
              options: widget.optionControllers.map((c) => c.text).toList(),
              hints: widget.hintControllers.map((c) => c.text).toList(),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: vm.isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.black)),
                )
              : const Text(
                  '이 문제만 즉시 저장',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}
