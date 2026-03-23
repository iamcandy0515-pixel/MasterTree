import 'package:flutter/material.dart';

class QuestionExplanationModule extends StatefulWidget {
  final TextEditingController questionController;
  final TextEditingController explanationController;

  const QuestionExplanationModule({
    super.key,
    required this.questionController,
    required this.explanationController,
  });

  @override
  State<QuestionExplanationModule> createState() =>
      _QuestionExplanationModuleState();
}

class _QuestionExplanationModuleState extends State<QuestionExplanationModule> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '문제 및 해설 검토',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: widget.questionController,
          maxLines: null,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            labelText: '문제 내용',
            labelStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: widget.explanationController,
          maxLines: null,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            labelText: '해설 내용',
            labelStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}
