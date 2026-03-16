import 'package:flutter/material.dart';

class QuizHintCard extends StatefulWidget {
  final String initialText;
  final Function(String) onTextChanged;

  const QuizHintCard({
    super.key,
    required this.initialText,
    required this.onTextChanged,
  });

  @override
  State<QuizHintCard> createState() => _QuizHintCardState();
}

class _QuizHintCardState extends State<QuizHintCard> {
  late final TextEditingController _controller;
  final Color primaryColor = const Color(0xFF2BEE8C);
  final Color surfaceDark = const Color(0xFF1A2E24);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _controller.addListener(() => widget.onTextChanged(_controller.text));
  }

  @override
  void didUpdateWidget(QuizHintCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialText != _controller.text) {
      _controller.text = widget.initialText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('힌트', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: '문제를 풀 때 도움이 되는 힌트를 입력하세요',
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
            filled: true,
            fillColor: surfaceDark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white10)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: primaryColor.withOpacity(0.5))),
          ),
        ),
      ],
    );
  }
}

