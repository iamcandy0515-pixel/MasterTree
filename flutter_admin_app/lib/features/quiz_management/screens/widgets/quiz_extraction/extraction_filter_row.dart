import 'package:flutter/material.dart';
import './extraction_dropdown.dart';

class ExtractionFilterRow extends StatelessWidget {
  final String? selectedSubject;
  final String? selectedYear;
  final String? selectedRound;
  final Function(String?) onSubjectChanged;
  final Function(int?) onYearChanged;
  final Function(int?) onRoundChanged;

  static const backgroundDark = Color(0xFF102219);

  const ExtractionFilterRow({
    super.key,
    required this.selectedSubject,
    required this.selectedYear,
    required this.selectedRound,
    required this.onSubjectChanged,
    required this.onYearChanged,
    required this.onRoundChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: backgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: ExtractionDropdown(
              hint: '과목',
              value: selectedSubject,
              items: const ['산림기사', '산림산업기사'],
              onChanged: onSubjectChanged,
            ),
          ),
          _buildDivider(),
          Expanded(
            child: ExtractionDropdown(
              hint: '연도',
              value: selectedYear,
              items: List.generate(14, (i) => (2013 + i).toString()),
              onChanged: (val) => onYearChanged(int.tryParse(val ?? '')),
            ),
          ),
          _buildDivider(),
          Expanded(
            child: ExtractionDropdown(
              hint: '회차',
              value: selectedRound,
              items: const ['1', '2', '3', '4'],
              onChanged: (val) => onRoundChanged(int.tryParse(val ?? '')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 20,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.white10,
    );
  }
}
