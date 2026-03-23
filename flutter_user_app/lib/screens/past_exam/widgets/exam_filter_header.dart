import 'package:flutter/material.dart';
import '../../../../core/design_system.dart';

class ExamFilterHeader extends StatelessWidget {
  final String? selectedSubject;
  final String? selectedYear;
  final String? selectedSession;
  final List<String> subjects;
  final List<String> years;
  final List<String> sessions;
  final Function(String?) onSubjectChanged;
  final Function(String?) onYearChanged;
  final Function(String?) onSessionChanged;

  const ExamFilterHeader({
    super.key,
    required this.selectedSubject,
    required this.selectedYear,
    required this.selectedSession,
    required this.subjects,
    required this.years,
    required this.sessions,
    required this.onSubjectChanged,
    required this.onYearChanged,
    required this.onSessionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Text(
            '조건',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: _FilterDropdown(
              hint: '과목',
              value: selectedSubject,
              items: subjects,
              onChanged: onSubjectChanged,
            ),
          ),
          Expanded(
            child: _FilterDropdown(
              hint: '연도',
              value: selectedYear,
              items: years,
              onChanged: onYearChanged,
            ),
          ),
          Expanded(
            child: _FilterDropdown(
              hint: '회차',
              value: selectedSession,
              items: sessions,
              onChanged: onSessionChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: false,
          dropdownColor: AppColors.surfaceDark,
          hint: Text(
            hint,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          value: value,
          icon: const Icon(
            Icons.expand_more,
            color: AppColors.primary,
            size: 16,
          ),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
        ),
      ),
    );
  }
}
