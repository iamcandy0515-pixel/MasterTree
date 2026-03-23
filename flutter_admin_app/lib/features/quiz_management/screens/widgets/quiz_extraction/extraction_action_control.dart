import 'package:flutter/material.dart';
import './extraction_dropdown.dart';

class ExtractionActionControl extends StatefulWidget {
  final int selectedQuestionNumber;
  final bool isLoading;
  final Function(int) onQuestionNumberChanged;
  final Future<void> Function() onExtract;

  const ExtractionActionControl({
    super.key,
    required this.selectedQuestionNumber,
    required this.isLoading,
    required this.onQuestionNumberChanged,
    required this.onExtract,
  });

  @override
  State<ExtractionActionControl> createState() => _ExtractionActionControlState();
}

class _ExtractionActionControlState extends State<ExtractionActionControl> {
  String _floatingMessage = '';
  static const primaryColor = Color(0xFF2BEE8C);
  static const backgroundDark = Color(0xFF102219);

  void _showLocalMessage(String message) {
    if (!mounted) return;
    setState(() => _floatingMessage = message);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _floatingMessage = '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '문제번호:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            _buildCompactNumberBox(
              value: widget.selectedQuestionNumber.toString(),
              items: List.generate(15, (i) => (i + 1).toString()),
              onChanged: (val) {
                final qNum = int.tryParse(val ?? '1');
                if (qNum != null) widget.onQuestionNumberChanged(qNum);
              },
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: widget.isLoading
                  ? null
                  : () async {
                      _showLocalMessage('추출 시작');
                      await widget.onExtract();
                      if (mounted) _showLocalMessage('추출 완료');
                    },
              icon: const Icon(Icons.auto_awesome, size: 18, color: primaryColor),
              label: const Text(
                'PDF 추출',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: backgroundDark,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Colors.white10),
                ),
              ),
            ),
          ],
        ),
        AnimatedOpacity(
          opacity: _floatingMessage.isNotEmpty ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Padding(
            padding: const EdgeInsets.only(top: 4, left: 0),
            child: SizedBox(
              height: 16,
              child: Text(
                _floatingMessage,
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactNumberBox({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      width: 60,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: ExtractionDropdown(
        hint: '',
        value: value,
        items: items,
        onChanged: onChanged,
        isDense: true,
        isExpanded: false,
      ),
    );
  }
}
