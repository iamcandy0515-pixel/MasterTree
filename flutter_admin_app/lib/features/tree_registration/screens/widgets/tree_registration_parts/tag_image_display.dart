import 'package:flutter/material.dart';

class TagImageDisplay extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onDelete;

  const TagImageDisplay({
    super.key,
    required this.imageUrl,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image, color: Colors.white10),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
            onPressed: onDelete,
            style: IconButton.styleFrom(backgroundColor: Colors.black54),
          ),
        ),
      ],
    );
  }
}
