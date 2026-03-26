import 'package:flutter/material.dart';

/// 이미지별로 상세 힌트를 입력받는 별도 위젯 (Rule 1-1: 200줄 분리 원칙 준수)
class AddTreeImageHintInput extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final String label;

  const AddTreeImageHintInput({
    super.key,
    required this.hint,
    required this.onChanged,
    required this.label,
  });

  @override
  State<AddTreeImageHintInput> createState() => _AddTreeImageHintInputState();
}

class _AddTreeImageHintInputState extends State<AddTreeImageHintInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.hint);
  }

  @override
  void didUpdateWidget(AddTreeImageHintInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hint != widget.hint && _controller.text != widget.hint) {
      _controller.text = widget.hint;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        style: const TextStyle(color: Colors.white, fontSize: 11, height: 1.2),
        maxLines: 1,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          border: InputBorder.none,
          hintText: '${widget.label} 힌트...',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.3),
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
