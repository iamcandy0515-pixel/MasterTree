import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/api_service.dart';
import '../../../core/design_system.dart';
import '../../../core/widgets/fullscreen_image_viewer.dart';

class QuizImageDisplay extends StatelessWidget {
  final String imageUrl;

  const QuizImageDisplay({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) return const SizedBox.shrink();

    return Center(
      child: Container(
        width: 320,
        height: 320,
        decoration: BoxDecoration(
          color: AppColors.backgroundDark.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullscreenImageViewer(
                    imageUrl: imageUrl,
                    title: '수목 식별 이미지',
                  ),
                ),
              );
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                // [최적화 1] 원본 이미지 + 메모리 캐싱 (RAM 절감)
                CachedNetworkImage(
                  imageUrl: ApiService.getProxyImageUrl(imageUrl, width: 600),
                  fit: BoxFit.cover,
                  memCacheWidth: 600, // 기기 메모리 캐시 최적화
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                  errorWidget: (context, url, error) => _buildErrorWidget(),
                ),

                // [최적화 2] BackdropFilter 제거 (GPU 부하 절감)
                // 하단에 텍스트나 아이콘의 가공성을 높이기 위한 가벼운 그라데이션
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                        ],
                        stops: const [0.7, 1.0],
                      ),
                    ),
                  ),
                ),

                // [디자인] 확대 아이콘
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.zoom_in, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.park, size: 60, color: Colors.grey),
        SizedBox(height: 12),
        Text(
          '이미지를 불러올 수 없습니다.',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}

