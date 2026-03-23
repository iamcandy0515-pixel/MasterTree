import 'package:flutter/material.dart';

class BulkFilterPanel extends StatelessWidget {
  final String? selectedSubject;
  final String? selectedYear;
  final String? selectedRound;
  final List<String> subjects;
  final List<String> years;
  final List<String> rounds;
  final String statusMessage;
  final Function(String?) onSubjectChanged;
  final Function(String?) onYearChanged;
  final Function(String?) onRoundChanged;
  
  static const primaryColor = Color(0xFF2BEE8C);
  static const backgroundDark = Color(0xFF102219);
  static const surfaceDark = Color(0xFF1A2E24);

  const BulkFilterPanel({
    super.key,
    required this.selectedSubject,
    required this.selectedYear,
    required this.selectedRound,
    required this.subjects,
    required this.years,
    required this.rounds,
    required this.statusMessage,
    required this.onSubjectChanged,
    required this.onYearChanged,
    required this.onRoundChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildDropDown('과목', selectedSubject, subjects, onSubjectChanged)),
              const SizedBox(width: 8),
              Expanded(child: _buildDropDown('년도', selectedYear, years, onYearChanged)),
              const SizedBox(width: 8),
              Expanded(child: _buildDropDown('회차', selectedRound, rounds, onRoundChanged)),
            ],
          ),
          if (statusMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                statusMessage,
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropDown(String hint, String? value, List<String> items, Function(String?) onChanged) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: backgroundDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(hint, style: const TextStyle(color: Colors.white24, fontSize: 13)),
          dropdownColor: surfaceDark,
          icon: const Icon(Icons.arrow_drop_down, color: primaryColor),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
