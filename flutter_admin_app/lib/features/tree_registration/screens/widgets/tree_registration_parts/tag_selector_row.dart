import 'package:flutter/material.dart';

class TagSelectorRow extends StatelessWidget {
  final String activeTag;
  final Map<String, String> tags;
  final Map<String, dynamic> taggedImages;
  final Function(String) onTagSelected;

  const TagSelectorRow({
    super.key,
    required this.activeTag,
    required this.tags,
    required this.taggedImages,
    required this.onTagSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tags.entries.map((e) {
          final isSelected = activeTag == e.key;
          final hasImage = taggedImages.containsKey(e.key);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(e.value),
              selected: isSelected,
              onSelected: (selected) => onTagSelected(e.key),
              selectedColor: const Color(0xFF80F20D),
              backgroundColor: const Color(0xFF161B12),
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.black
                    : (hasImage ? Colors.white : Colors.white38),
                fontWeight: FontWeight.bold,
              ),
              avatar: hasImage
                  ? const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green,
                    )
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }
}
