import 'package:flutter/material.dart';

import 'package:flutter_admin_app/features/trees/models/tree.dart';

class TreeCard extends StatelessWidget {
  final Tree tree;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  // This could be passed in or defined in a constants file
  static const List<String> _requiredCategories = [
    'main',
    'leaf',
    'bark',
    'flower',
    'fruit',
  ];

  const TreeCard({
    super.key,
    required this.tree,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final registeredTypes = tree.images.map((img) => img.imageType).toSet();
    final registeredCount = _requiredCategories
        .where((t) => registeredTypes.contains(t))
        .length;
    final totalRequired = _requiredCategories.length;
    final isComplete = registeredCount == totalRequired;

    // Main image for background
    final mainImageEntry = tree.images.isNotEmpty
        ? (tree.images.where((i) => i.imageType == 'main').firstOrNull ??
              tree.images.first)
        : null;

    return Card(
      elevation: 4,
      color: const Color(0xFF2C2C2C),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isComplete
              ? const Color(0xFFCCFF00).withOpacity(0.5)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        overlayColor: MaterialStateProperty.all(
          const Color(0xFFCCFF00).withOpacity(0.1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Area
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (mainImageEntry != null)
                    Image.network(
                      mainImageEntry.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: Colors.grey[800]),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                            color: const Color(0xFFCCFF00),
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      color: Colors.grey[850],
                      child: const Icon(
                        Icons.forest,
                        size: 48,
                        color: Colors.white24,
                      ),
                    ),

                  // Category Icons Row (Bottom Left or custom position)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: _requiredCategories.map((type) {
                          final count = tree.images
                              .where((img) => img.imageType == type)
                              .length;
                          final hasImage = count > 0;

                          IconData iconData;
                          switch (type) {
                            case 'main':
                              iconData = Icons.star;
                              break;
                            case 'leaf':
                              iconData = Icons.eco;
                              break;
                            case 'bark':
                              iconData = Icons.texture;
                              break; // or grid_on
                            case 'flower':
                              iconData = Icons.local_florist;
                              break;
                            case 'fruit':
                              iconData = Icons.circle;
                              break; // or apple if available
                            default:
                              iconData = Icons.image;
                          }

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                iconData,
                                size: 14,
                                color: hasImage
                                    ? const Color(0xFFCCFF00)
                                    : Colors.grey,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$count',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: hasImage ? Colors.white : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // Delete Button (Top Left)
                  if (onDelete != null)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: GestureDetector(
                        onTap: onDelete,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ),

                  // Image Count Badge (Top Right)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isComplete
                              ? const Color(0xFFCCFF00)
                              : Colors.white24,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isComplete ? Icons.check_circle : Icons.image,
                            size: 14,
                            color: isComplete
                                ? const Color(0xFFCCFF00)
                                : Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isComplete
                                ? '완료'
                                : (registeredCount == 0
                                      ? '미등록'
                                      : '$registeredCount/5'),
                            style: TextStyle(
                              color: isComplete
                                  ? const Color(0xFFCCFF00)
                                  : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info Area
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tree.nameKr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tree.scientificName ?? '',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    // Category Badge
                    if (tree.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: tree.category == '침엽수'
                              ? Colors.cyanAccent.withOpacity(0.2)
                              : Colors.greenAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: tree.category == '침엽수'
                                ? Colors.cyanAccent.withOpacity(0.5)
                                : Colors.greenAccent.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          tree.category!,
                          style: TextStyle(
                            color: tree.category == '침엽수'
                                ? Colors.cyanAccent
                                : Colors.greenAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    // Progress Bar (Visual Indicator)
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: totalRequired > 0
                                ? registeredCount / totalRequired
                                : 0,
                            backgroundColor: Colors.white10,
                            color: isComplete
                                ? const Color(0xFFCCFF00)
                                : (registeredCount == 0
                                      ? Colors.grey
                                      : Colors.orangeAccent),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
