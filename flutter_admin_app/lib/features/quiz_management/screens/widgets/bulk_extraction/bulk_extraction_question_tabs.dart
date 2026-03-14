import 'package:flutter/material.dart';

class BulkExtractionQuestionTabs extends StatelessWidget {
  final int startNumber;
  final int endNumber;
  final int selectedTabIndex;
  final ScrollController scrollController;
  final Map<int, Map<String, dynamic>> extractedQuizzes;
  final bool Function(int) hasImage;
  final Function(int) onTabSelected;

  static const primaryColor = Color(0xFF2BEE8C);
  static const backgroundDark = Color(0xFF102219);
  static const surfaceDark = Color(0xFF1A2E24);

  const BulkExtractionQuestionTabs({
    super.key,
    required this.startNumber,
    required this.endNumber,
    required this.selectedTabIndex,
    required this.scrollController,
    required this.extractedQuizzes,
    required this.hasImage,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: (endNumber >= startNumber && startNumber > 0)
            ? (endNumber - startNumber + 1)
            : 0,
        itemBuilder: (context, index) {
          final qNum = startNumber + index;
          final isSelected = selectedTabIndex == qNum;
          final isExtracted = extractedQuizzes.containsKey(qNum);
          final showImageIndicator = hasImage(qNum);

          return GestureDetector(
            onTap: () => onTabSelected(qNum),
            child: Container(
              margin: const EdgeInsets.only(right: 3),
              width: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor
                    : (isExtracted ? surfaceDark : Colors.transparent),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.white10,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '$qNum',
                    style: TextStyle(
                      color: isSelected
                          ? backgroundDark
                          : (isExtracted ? Colors.white : Colors.white24),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  if (showImageIndicator)
                    Positioned(
                      top: 1,
                      right: 1,
                      child: Icon(
                        Icons.image,
                        size: 8,
                        color: isSelected
                            ? backgroundDark
                            : primaryColor.withValues(alpha: 0.8),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
