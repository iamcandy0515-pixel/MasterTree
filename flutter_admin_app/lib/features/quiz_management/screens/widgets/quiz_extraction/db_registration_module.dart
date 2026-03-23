import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/quiz_extraction_step2_viewmodel.dart';
import 'package:flutter_admin_app/core/utils/snackbar_util.dart';

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
  static const primaryColor = Color(0xFF2BEE8C);

  Future<void> _saveToDb() async {
    final vm = context.read<QuizExtractionStep2ViewModel>();

    if (vm.extractedBlock == null) return;

    if (vm.initialSubject == null ||
        vm.initialYear == null ||
        vm.initialRound == null ||
        vm.selectedQuestion <= 0) {
      if (mounted) {
        SnackBarUtil.showFloating(
          context,
          '필수 key 에러: (과목, 년도, 회차, 문제번호) 정보를 확인해주세요.',
          isError: true,
        );
      }
      return;
    }

    try {
      await vm.saveToDb(
        questionText: widget.questionController.text,
        explanationText: widget.explanationController.text,
        hintTexts: widget.hintControllers.map((c) => c.text).toList(),
        optionTexts: widget.optionControllers.map((c) => c.text).toList(),
      );
      if (mounted) {
        SnackBarUtil.showFloating(context, '기출문제가 성공적으로 저장되었습니다.');
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
    return TextButton(
      onPressed: vm.extractedBlock == null ? null : _saveToDb,
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text(
        '문제 등록',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
}
