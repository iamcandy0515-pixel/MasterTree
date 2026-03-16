import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/widgets/fullscreen_image_viewer.dart';

class QuizContentCard extends StatefulWidget {
  final String initialText;
  final List<dynamic> blocks;
  final bool isExpanded;
  final Function(String) onTextChanged;
  final VoidCallback onToggleExpand;
  final Function(XFile) onUploadImage;
  final Function(int) onRemoveImage;

  const QuizContentCard({
    super.key,
    required this.initialText,
    required this.blocks,
    required this.isExpanded,
    required this.onTextChanged,
    required this.onToggleExpand,
    required this.onUploadImage,
    required this.onRemoveImage,
  });

  @override
  State<QuizContentCard> createState() => _QuizContentCardState();
}

class _QuizContentCardState extends State<QuizContentCard> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _controller.addListener(() => widget.onTextChanged(_controller.text));
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2BEE8C);
    const surfaceDark = Color(0xFF1A2E24);
    final imageBlocks = widget.blocks.where((b) => b['type'] == 'image').toList();
    final hasImages = imageBlocks.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('臾몄젣', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              children: [
                if (hasImages)
                  IconButton(
                    icon: Icon(widget.isExpanded ? Icons.keyboard_arrow_up : Icons.photo_library, color: primaryColor.withOpacity(0.8), size: 20),
                    onPressed: widget.onToggleExpand,
                  ),
                IconButton(
                  icon: const Icon(Icons.add_photo_alternate, color: primaryColor, size: 20),
                  onPressed: () async {
                    final img = await _picker.pickImage(source: ImageSource.gallery);
                    if (img != null) widget.onUploadImage(img);
                  },
                ),
              ],
            ),
          ],
        ),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          maxLines: 3,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: surfaceDark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white10)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: primaryColor)),
          ),
        ),
        const SizedBox(height: 12),
        _buildPasteGuide(hasImages, surfaceDark, primaryColor),
        if (hasImages && widget.isExpanded) _buildImageListView(widget.blocks, primaryColor),
      ],
    );
  }

  Widget _buildPasteGuide(bool hasImages, Color surfaceDark, Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: hasImages ? 12 : 24),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _focusNode.hasFocus ? primaryColor : Colors.white10, width: 2),
      ),
      child: Column(
        children: [
          Icon(Icons.content_paste_go, color: _focusNode.hasFocus ? primaryColor : Colors.white24, size: hasImages ? 24 : 32),
          const SizedBox(height: 8),
          Text(
            '?대┰蹂대뱶 ?대?吏瑜?Ctrl+V濡?遺숈뿬?ｌ쑝?몄슂',
            style: TextStyle(color: _focusNode.hasFocus ? primaryColor : Colors.white54, fontSize: hasImages ? 11 : 13),
          ),
        ],
      ),
    );
  }

  Widget _buildImageListView(List<dynamic> blocks, Color primaryColor) {
    final images = blocks.asMap().entries.where((e) => e.value['type'] == 'image').toList();
    return Container(
      constraints: const BoxConstraints(maxHeight: 350),
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: images.length,
        itemBuilder: (context, index) {
          final entry = images[index];
          final url = entry.value['content'].toString();
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10), color: Colors.black26),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FullscreenImageViewer(imageUrl: url, title: '臾몄젣 ?대?吏'))),
                  child: CachedNetworkImage(imageUrl: url, width: double.infinity, fit: BoxFit.contain),
                ),
                Positioned(
                  top: 8, right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => widget.onRemoveImage(entry.key),
                    style: IconButton.styleFrom(backgroundColor: Colors.black54),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

