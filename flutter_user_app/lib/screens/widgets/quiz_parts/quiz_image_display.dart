import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/api_service.dart';
import '../../../core/design_system.dart';
import '../../../core/widgets/fullscreen_image_viewer.dart';

class QuizImageDisplay extends StatelessWidget {
  final String imageUrl;
  final String? thumbnailUrl;

  const QuizImageDisplay({
    super.key,
    required this.imageUrl,
    this.thumbnailUrl,
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
              Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => FullscreenImageViewer(
                    imageUrl: imageUrl,
                    title: '수목 식별 이미지',
                  ),
                ),
              );
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                // [마스킹 1] 중앙 집중 크롭 (상/하단 텍스트 제거)
                Transform.scale(
                  scale: 1.25, // 125% 확대하여 가장자리 텍스트 영역을 Clip 밖으로 밀어냄
                  alignment: Alignment.center,
                  child: CachedNetworkImage(
                    imageUrl: ApiService.getProxyImageUrl(imageUrl, width: 450),
                    fit: BoxFit.cover,
                    memCacheWidth: 450,
                    // [최적화] 썸네일을 먼저 보여주는 프로그레시브 로딩
                    placeholder: (BuildContext context, String url) => thumbnailUrl != null 
                      ? Image.network(
                          ApiService.getProxyImageUrl(thumbnailUrl!, width: 300),
                          fit: BoxFit.cover,
                        )
                      : const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                    errorWidget: (BuildContext context, String url, dynamic error) => _buildErrorWidget(),
                  ),
                ),

                // [마스킹 2] 상단 텍스트 유출 방지용 그라데이션
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 60,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.85),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // [마스킹 3] 하단 텍스트 및 그라데이션 강화
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 60,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.85),
                          Colors.transparent,
                        ],
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

