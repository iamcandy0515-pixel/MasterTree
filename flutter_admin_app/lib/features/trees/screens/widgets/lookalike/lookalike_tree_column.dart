import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_admin_app/features/trees/models/tree_group.dart';
import 'package:flutter_admin_app/core/api/node_api.dart';

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
    String? thumbUrl;

    if (selectedTab == 'leaf') {
      imageUrl = member.leafImageUrl;
      thumbUrl = member.leafThumbnailUrl;
    } else if (selectedTab == 'bark') {
      imageUrl = member.barkImageUrl;
      thumbUrl = member.barkThumbnailUrl;
    } else if (selectedTab == 'flower') {
      imageUrl = member.flowerImageUrl;
      thumbUrl = member.flowerThumbnailUrl;
    } else if (selectedTab == 'fruit') {
      imageUrl = member.fruitImageUrl;
      thumbUrl = member.fruitThumbnailUrl;
    } else {
      imageUrl = member.imageUrl;
      // Representative image might not have a separate thumbnail in this model easily
      thumbUrl = null; 
    }

    // [전략 변경] 썸네일이 있으면 최우선 사용, 없으면 원본 프록시 사용
    final effectiveUrl = thumbUrl ?? imageUrl;

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
          _buildImageCell(context, effectiveUrl, originalUrl: imageUrl),
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

  Widget _buildImageCell(BuildContext context, String? imageUrl, {String? originalUrl}) {
    return SizedBox(
      height: imageRowHeight,
      child: imageUrl != null
          ? GestureDetector(
              onTap: () => _showFullScreenImage(
                  context, originalUrl ?? imageUrl, member.treeName),
              child: OptimizedNetworkImage(
                imageUrl: imageUrl, // 썸네일이 있으면 썸네일, 없으면 원본
                width: 400,
                fit: BoxFit.cover,
              ),
            )
          : Container(
              color: Colors.grey[850],
              child: const Center(
                child: Text('이미지 없음',
                    style: TextStyle(color: Colors.white24, fontSize: 12)),
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
    showDialog<dynamic>(
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
              child: OptimizedNetworkImage(
                imageUrl: url,
                width: 1000, // 상세 미리보기는 고화질
                fit: BoxFit.contain,
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
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
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

/// [Added] 에러 발생 시 새로고침 기능이 포함된 최적화 이미지 위젯
class OptimizedNetworkImage extends StatefulWidget {
  final String imageUrl;
  final int? width;
  final int? height;
  final BoxFit fit;

  const OptimizedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  State<OptimizedNetworkImage> createState() => _OptimizedNetworkImageState();
}

class _OptimizedNetworkImageState extends State<OptimizedNetworkImage> {
  int _retryKey = 0; // 재시도를 위한 키 값

  void _handleReload() async {
    // 1. 캐시 강제 삭제
    final proxiedUrl = NodeApi.getProxyImageUrl(widget.imageUrl,
        width: widget.width, height: widget.height);
    await CachedNetworkImage.evictFromCache(proxiedUrl);

    // 2. 위젯 리렌더링 유발
    setState(() {
      _retryKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final proxiedUrl = NodeApi.getProxyImageUrl(widget.imageUrl,
        width: widget.width, height: widget.height);

    return CachedNetworkImage(
      key: ValueKey('${proxiedUrl}_$_retryKey'), // 키가 바뀌면 새로 로드함
      imageUrl: proxiedUrl,
      fit: widget.fit,
      memCacheWidth: widget.width,
      memCacheHeight: widget.height,
      placeholder: (context, url) => Container(
        color: Colors.grey[900],
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF80F20D),
          ),
        ),
      ),
      errorWidget: (context, url, dynamic error) => Container(
        color: Colors.grey[850],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.broken_image, color: Colors.white24, size: 32),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _handleReload,
              icon: const Icon(Icons.refresh, size: 16, color: Color(0xFF80F20D)),
              label: const Text('새로고침',
                  style: TextStyle(color: Color(0xFF80F20D), fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
