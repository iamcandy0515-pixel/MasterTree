import 'package:flutter/material.dart';

class QuizOptionsCard extends StatefulWidget {
  final String correctOption;
  final List<String> incorrectOptions;
  final bool isGenerating;
  final Function(String) onCorrectOptionChanged;
  final Function(int, String) onIncorrectOptionChanged;
  final VoidCallback onAiGenerate;

  const QuizOptionsCard({
    super.key,
    required this.correctOption,
    required this.incorrectOptions,
    required this.isGenerating,
    required this.onCorrectOptionChanged,
    required this.onIncorrectOptionChanged,
    required this.onAiGenerate,
  });

  @override
  State<QuizOptionsCard> createState() => _QuizOptionsCardState();
}

class _QuizOptionsCardState extends State<QuizOptionsCard> {
  late final TextEditingController _correctController;
  late final List<TextEditingController> _incorrectControllers;
  final Color primaryColor = const Color(0xFF2BEE8C);
  final Color surfaceDark = const Color(0xFF1A2E24);
  final Color aiColor = const Color(0xFF8B5CF6);

  @override
  void initState() {
    super.initState();
    _correctController = TextEditingController(text: widget.correctOption);
    _correctController.addListener(() => widget.onCorrectOptionChanged(_correctController.text));
    _incorrectControllers = widget.incorrectOptions
        .map((opt) => TextEditingController(text: opt))
        .toList();

    for (int i = 0; i < _incorrectControllers.length; i++) {
        _incorrectControllers[i].addListener(() => widget.onIncorrectOptionChanged(i, _incorrectControllers[i].text));
    }
  }

  @override
  void didUpdateWidget(QuizOptionsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.correctOption != _correctController.text) {
      _correctController.text = widget.correctOption;
    }
    if (widget.incorrectOptions.length != _incorrectControllers.length) {
      // Re-initialize if length changed
      for (var c in _incorrectControllers) {
        c.dispose();
      }
      _incorrectControllers.clear();
      _incorrectControllers.addAll(widget.incorrectOptions.map((opt) => TextEditingController(text: opt)));
       for (int i = 0; i < _incorrectControllers.length; i++) {
        _incorrectControllers[i].addListener(() => widget.onIncorrectOptionChanged(i, _incorrectControllers[i].text));
      }
    } else {
      for (int i = 0; i < widget.incorrectOptions.length; i++) {
        if (widget.incorrectOptions[i] != _incorrectControllers[i].text) {
          _incorrectControllers[i].text = widget.incorrectOptions[i];
        }
      }
    }
  }

  @override
  void dispose() {
    _correctController.dispose();
    for (var c in _incorrectControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('?뺣떟 諛?蹂닿린', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            if (widget.isGenerating)
              SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: primaryColor, strokeWidth: 2))
            else
              _buildAIAssistantButton('AI ?ㅻ떟 ?앹꽦', Icons.auto_awesome, widget.onAiGenerate, aiColor),
          ],
        ),
        const SizedBox(height: 12),
        _buildOptionField('?뺣떟', _correctController, isCorrect: true),
        const SizedBox(height: 8),
        ..._incorrectControllers.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildOptionField('?ㅻ떟 ${e.key + 1}', e.value, isCorrect: false),
            )),
      ],
    );
  }

  Widget _buildOptionField(String label, TextEditingController controller, {required bool isCorrect}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isCorrect ? primaryColor : Colors.white54, fontSize: 12),
        filled: true,
        fillColor: surfaceDark,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isCorrect ? primaryColor.withOpacity(0.3) : Colors.white10)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isCorrect ? primaryColor : Colors.white38)),
      ),
    );
  }

  Widget _buildAIAssistantButton(String label, IconData icon, VoidCallback onPressed, Color aiColor) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: aiColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: aiColor.withOpacity(0.5))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: aiColor),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: aiColor, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

