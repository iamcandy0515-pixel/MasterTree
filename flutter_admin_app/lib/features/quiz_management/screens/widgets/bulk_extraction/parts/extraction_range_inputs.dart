import 'package:flutter/material.dart';

class ExtractionRangeInputs extends StatelessWidget {
  final TextEditingController startController;
  final TextEditingController endController;
  final Function(String) onStartChanged;
  final Function(String) onEndChanged;
  final Color surfaceDark;

  const ExtractionRangeInputs({
    super.key,
    required this.startController,
    required this.endController,
    required this.onStartChanged,
    required this.onEndChanged,
    required this.surfaceDark,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        const Text(
          '범위:',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        _buildNumberInput('시작', startController, onStartChanged),
        const Text(
          '~',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
        _buildNumberInput('종료', endController, onEndChanged),
      ],
    );
  }

  Widget _buildNumberInput(
    String label,
    TextEditingController controller,
    Function(String) onChanged,
  ) {
    return Container(
      width: 48,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
