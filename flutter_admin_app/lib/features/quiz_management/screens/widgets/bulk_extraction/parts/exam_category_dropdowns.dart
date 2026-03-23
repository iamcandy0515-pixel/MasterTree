import 'package:flutter/material.dart';

class ExamCategoryDropdowns extends StatelessWidget {
  final String? subject;
  final int? year;
  final int? round;
  final Function(String?) onSubjectChanged;
  final Function(String?) onYearChanged;
  final Function(String?) onRoundChanged;
  final Color primaryColor;
  final Color surfaceDark;

  const ExamCategoryDropdowns({
    super.key,
    required this.subject,
    required this.year,
    required this.round,
    required this.onSubjectChanged,
    required this.onYearChanged,
    required this.onRoundChanged,
    required this.primaryColor,
    required this.surfaceDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDropDown(
              hint: '과목',
              value: subject,
              items: const ['산림기사', '산림산업기사'],
              onChanged: onSubjectChanged,
            ),
          ),
          _buildBannerDivider(),
          Expanded(
            child: _buildDropDown(
              hint: '연도',
              value: year?.toString(),
              items: List.generate(14, (i) => (2013 + i).toString()),
              onChanged: onYearChanged,
            ),
          ),
          _buildBannerDivider(),
          Expanded(
            child: _buildDropDown(
              hint: '회차',
              value: round?.toString(),
              items: const ['1', '2', '3', '4'],
              onChanged: onRoundChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropDown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      height: 44,
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: const TextStyle(color: Colors.white38, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
          dropdownColor: surfaceDark,
          icon: Icon(
            Icons.arrow_drop_down,
            color: primaryColor,
            size: 20,
          ),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildBannerDivider() {
    return Container(
      height: 20,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.white10,
    );
  }
}
