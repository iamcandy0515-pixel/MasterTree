import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TagUploadActions extends StatelessWidget {
  final bool isUploading;
  final Function(XFile) onPickImage;
  final VoidCallback onPasteImage;
  final VoidCallback onSearchGoogle;

  const TagUploadActions({
    super.key,
    required this.isUploading,
    required this.onPickImage,
    required this.onPasteImage,
    required this.onSearchGoogle,
  });

  @override
  Widget build(BuildContext context) {
    if (isUploading) {
      return Container(
        height: 154,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF80F20D)),
        ),
      );
    }

    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            final picker = ImagePicker();
            final file = await picker.pickImage(source: ImageSource.gallery);
            if (file != null) onPickImage(file);
          },
          child: Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white10,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.add_a_photo_outlined,
                  color: Colors.white38,
                  size: 28,
                ),
                SizedBox(height: 8),
                Text(
                  '클릭하여 이미지 파일 추가',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPasteImage,
                icon: const Icon(Icons.content_paste, size: 18),
                label: const Text('붙여넣기', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white10),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onSearchGoogle,
                icon: const Icon(Icons.search, size: 18),
                label: const Text('구글 검색', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white10),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
