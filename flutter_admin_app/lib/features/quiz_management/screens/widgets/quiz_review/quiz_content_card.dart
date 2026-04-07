import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:image_picker/image_picker.dart';

class QuizContentCard extends StatefulWidget {
  final String initialText;
  final List<dynamic> blocks;
  final bool isExpanded;
  final Function(String) onTextChanged;
  final VoidCallback onToggleExpand;
  final Function(XFile) onUploadImage;
  final Function(int) onRemoveImage;
  final Function(Uint8List, String)? onPasteImage;

  const QuizContentCard({
    super.key,
    required this.initialText,
    required this.blocks,
    required this.isExpanded,
    required this.onTextChanged,
    required this.onToggleExpand,
    required this.onUploadImage,
    required this.onRemoveImage,
    this.onPasteImage,
  });

  @override
  State<QuizContentCard> createState() => _QuizContentCardState();
}

class _QuizContentCardState extends State<QuizContentCard> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();
  bool _showPasteBox = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _controller.addListener(() => widget.onTextChanged(_controller.text));
    _focusNode.addListener(() => setState(() {}));
    _focusNode.onKeyEvent = (node, event) {
      if (event is KeyDownEvent) {
        final isV = event.logicalKey == LogicalKeyboardKey.keyV;
        final keys = HardwareKeyboard.instance.logicalKeysPressed;
        final isCtrlOrCmd = keys.contains(LogicalKeyboardKey.controlLeft) || 
                            keys.contains(LogicalKeyboardKey.controlRight) ||
                            keys.contains(LogicalKeyboardKey.metaLeft) || 
                            keys.contains(LogicalKeyboardKey.metaRight);
        if (isV && isCtrlOrCmd) {
          _submitPaste();
          return KeyEventResult.ignored;
        }
      }
      return KeyEventResult.ignored;
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _togglePasteBox() {
    setState(() {
      _showPasteBox = !_showPasteBox;
    });
  }

  Future<void> _submitPaste() async {
    final imageBytes = await Pasteboard.image;
    if (imageBytes != null && widget.onPasteImage != null) {
      if (!widget.isExpanded) {
        widget.onToggleExpand();
      }
      setState(() => _showPasteBox = false);
      final fileName = 'pasted_image_${DateTime.now().millisecondsSinceEpoch}.png';
      widget.onPasteImage!(imageBytes, fileName);
    } else if (imageBytes == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ 클립보드에 이미지가 없습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2BEE8C);
    const surfaceDark = Color(0xFF1A2E24);
    final imageBlocks = widget.blocks.where((dynamic b) => b is Map && b['type'] == 'image').toList();
    final hasImages = imageBlocks.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('문제',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_photo_alternate,
                      color: primaryColor, size: 20),
                  tooltip: '이미지 추가 (갤러리)',
                  onPressed: () async {
                    final img = await _picker.pickImage(source: ImageSource.gallery);
                    if (img != null) widget.onUploadImage(img);
                  },
                ),
                IconButton(
                  onPressed: _togglePasteBox,
                  icon: Icon(Icons.paste_outlined, color: _showPasteBox ? Colors.white : primaryColor, size: 20),
                  tooltip: '클립보드 이미지 붙여넣기 영역 열기/닫기',
                ),
                IconButton(
                  icon: Icon(
                      widget.isExpanded ? Icons.keyboard_arrow_up : Icons.photo_library_outlined,
                      color: hasImages ? primaryColor : Colors.white38,
                      size: 20),
                  tooltip: '이미지 목록 펼치기/접기',
                  onPressed: widget.onToggleExpand,
                ),
              ],
            ),
          ],
        ),
        CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.keyV, control: true): _submitPaste,
            const SingleActivator(LogicalKeyboardKey.keyV, meta: true): _submitPaste,
          },
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLines: 3,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: _focusNode.hasFocus ? Colors.white.withOpacity(0.08) : surfaceDark,
              hintText: _focusNode.hasFocus ? 'Ctrl+V로 이미지 붙여넣기 가능' : null,
              hintStyle: TextStyle(color: primaryColor.withOpacity(0.4), fontSize: 11),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white10)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: primaryColor)),
            ),
          ),
        ),
        if (widget.isExpanded && hasImages) 
          _buildImageListView(widget.blocks),
          
        if (_showPasteBox)
          GestureDetector(
            onTap: _submitPaste,
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primaryColor.withOpacity(0.5), width: 1.5, style: BorderStyle.solid),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.paste_outlined, color: primaryColor, size: 28),
                    SizedBox(height: 8),
                    Text(
                      '여기를 클릭하여 클립보드 이미지를 바로 붙여넣으세요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageListView(List<dynamic> blocks) {
    final images = blocks.asMap().entries.where((e) => e.value is Map && e.value['type'] == 'image').toList();
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...images.map((entry) {
            final index = entry.key;
            final String imageUrl = entry.value['content'] as String? ?? '';
 
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white10),
                color: Colors.black26,
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 600),
                          child: (imageUrl.startsWith('http') || imageUrl.startsWith('blob'))
                              ? Image.network(imageUrl)
                              : Text('Invalid Image URL: $imageUrl', style: const TextStyle(color: Colors.redAccent)),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8, right: 8,
                    child: GestureDetector(
                      onTap: () => widget.onRemoveImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

        ],
      ),
    );
  }
}

