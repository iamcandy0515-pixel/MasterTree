import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_user_app/core/design_system.dart';
import 'package:flutter_user_app/core/api_service.dart';

class FullscreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final String? title;

  const FullscreenImageViewer({super.key, required this.imageUrl, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: title != null
            ? Text(
                title!,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              )
            : null,
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4.0,
          child: CachedNetworkImage(
            imageUrl: ApiService.getProxyImageUrl(imageUrl),
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            errorWidget: (context, url, error) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.broken_image, color: Colors.white24, size: 64),
                  SizedBox(height: 16),
                  Text(
                    '이미지를 불러올 수 없습니다.',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}
