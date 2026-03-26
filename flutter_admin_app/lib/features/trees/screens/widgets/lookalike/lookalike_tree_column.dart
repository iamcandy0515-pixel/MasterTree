import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_admin_app/features/trees/models/tree_group.dart';

class LookalikeTreeColumn extends StatelessWidget {
  final TreeGroupMember member;
  final String selectedTab;
  final double columnWidth;
  final double imageRowHeight;
  final double nameRowHeight;
  final double characteristicRowHeight;

  const LookalikeTreeColumn({
    super.key,
    required this.member,
    required this.selectedTab,
    this.columnWidth = 180.0,
    required this.imageRowHeight,
    required this.nameRowHeight,
    required this.characteristicRowHeight,
  });

  @override
  Widget build(BuildContext context) {
    // Determine image and hint based on selected tab
    String? imageUrl;
    if (selectedTab == 'leaf') {
      imageUrl = member.leafImageUrl;
    } else if (selectedTab == 'bark') {
      imageUrl = member.barkImageUrl;
    } else if (selectedTab == 'flower') {
      imageUrl = member.flowerImageUrl;
    } else if (selectedTab == 'fruit') {
      imageUrl = member.fruitImageUrl;
    } else {
      imageUrl = member.imageUrl;
    }

    String hintText;
    if (selectedTab == 'leaf') {
      hintText = member.imageHints['leaf'] ?? member.imageHints['leaves'] ?? member.imageHints['잎'] ?? '-';
    } else if (selectedTab == 'bark') {
      hintText = member.imageHints['bark'] ?? member.imageHints['수피'] ?? '-';
    } else if (selectedTab == 'flower') {
      hintText = member.imageHints['flower'] ?? member.imageHints['꽃'] ?? '-';
    } else if (selectedTab == 'fruit') {
      hintText = member.imageHints['fruit'] ?? member.imageHints['열매'] ?? '-';
    } else {
      hintText = '-';
    }

    return Container(
      width: columnWidth,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        children: [
          // 1. Image Cell with Fullscreen Dialog support
          _buildImageCell(context, imageUrl),
          const Divider(height: 1, color: Colors.white10),

          // 2. Name Cell
          _buildNameCell(),
          const Divider(height: 1, color: Colors.white10),

          // 3. Hint Cell (Key Characteristics)
          _buildHintCell(hintText),
        ],
      ),
    );
  }

  Widget _buildImageCell(BuildContext context, String? imageUrl) {
    return SizedBox(
      height: imageRowHeight,
      child: imageUrl != null
          ? GestureDetector(
              onTap: () => _showFullScreenImage(context, imageUrl, member.treeName),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                memCacheWidth: 400,
                placeholder: (context, url) => Container(
                  color: Colors.grey[900],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[850],
                  child: const Icon(Icons.broken_image, color: Colors.white24),
                ),
              ),
            )
          : Container(
              color: Colors.grey[850],
              child: const Center(
                child: Text('이미지 없음', style: TextStyle(color: Colors.white24, fontSize: 12)),
              ),
            ),
    );
  }

  Widget _buildNameCell() {
    return Container(
      height: nameRowHeight,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        member.treeName,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildHintCell(String hintText) {
    return Container(
      height: characteristicRowHeight,
      padding: const EdgeInsets.all(12),
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        child: Text(
          hintText,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String url, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: CachedNetworkImage(
                imageUrl: url,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            Positioned(
              top: 40,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
