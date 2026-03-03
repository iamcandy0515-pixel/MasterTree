import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
            imageUrl: imageUrl,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(color: Color(0xFF2BEE8C)),
            ),
            errorWidget: (context, url, error) => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
