import 'package:flutter/material.dart';
import '3_question_explanation_module.dart';
import '4_distractor_module.dart';
import '5_hint_module.dart';
import '6_related_question_module.dart';
import '7_db_registration_module.dart';

class QuizExtractionDataForm extends StatelessWidget {
  final TextEditingController questionController;
  final TextEditingController explanationController;
  final List<TextEditingController> optionControllers;
  final List<TextEditingController> hintControllers;
  final Color primaryColor;

  const QuizExtractionDataForm({
    super.key,
    required this.questionController,
    required this.explanationController,
    required this.optionControllers,
    required this.hintControllers,
    this.primaryColor = const Color(0xFF2BEE8C),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.edit_note,
              color: primaryColor,
              size: 22,
            ),
            const SizedBox(width: 8),
            const Text(
              '추출 데이터 상세',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            DbRegistrationModule(
              questionController: questionController,
              explanationController: explanationController,
              optionControllers: optionControllers,
              hintControllers: hintControllers,
            ),
          ],
        ),
        const SizedBox(height: 16),
        QuestionAndExplanationModule(
          questionController: questionController,
          explanationController: explanationController,
        ),
        const SizedBox(height: 12),
        DistractorModule(
          questionController: questionController,
          optionControllers: optionControllers,
        ),
        const SizedBox(height: 12),
        HintModule(
          questionController: questionController,
          explanationController: explanationController,
          hintControllers: hintControllers,
        ),
        const SizedBox(height: 12),
        RelatedQuestionModule(
          questionController: questionController,
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
