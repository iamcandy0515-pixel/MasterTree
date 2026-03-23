import 'package:flutter/material.dart';

class ExtractionDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;
  final bool isExpanded;
  final bool isDense;

  const ExtractionDropdown({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isExpanded = true,
    this.isDense = false,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        hint: Text(
          hint,
          style: const TextStyle(color: Colors.white38, fontSize: 13),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        isExpanded: isExpanded,
        isDense: isDense,
        dropdownColor: const Color(0xFF161B22),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
      ),
    );
  }
}
