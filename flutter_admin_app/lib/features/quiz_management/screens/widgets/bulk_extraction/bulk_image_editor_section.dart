import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pasteboard/pasteboard.dart';
import '../../../viewmodels/bulk_extraction_viewmodel.dart';


class BulkImageEditorSection extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final Function(String) onChanged;
  final int lines;
  final String field;
  final int selectedTabIndex;
  final BulkExtractionViewModel vm;

  const BulkImageEditorSection({
    super.key,
    required this.label,
    required this.controller,
    required this.onChanged,
    required this.lines,
    required this.field,
    required this.selectedTabIndex,
    required this.vm,
  });

  @override
  State<BulkImageEditorSection> createState() => _BulkImageEditorSectionState();
}

class _BulkImageEditorSectionState extends State<BulkImageEditorSection> {
  bool _isExpanded = false;
  bool _showPasteBox = false;
  final FocusNode _focusNode = FocusNode();
  static const primaryColor = Color(0xFF2BEE8C);

  @override
  void initState() {
    super.initState();
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
          return KeyEventResult.ignored; // 텍스트 붙여넣기도 통과시킴
        }
      }
      return KeyEventResult.ignored;
    };
  }

  @override
  void dispose() {
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
    if (imageBytes != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⏳ 클립보드 이미지 업로드 중...')),
        );
      }
      final fileName =
          'pasted_image_${DateTime.now().millisecondsSinceEpoch}.png';
      final success = await widget.vm.addImageBytesToQuiz(
          widget.selectedTabIndex, widget.field, imageBytes, fileName);
      if (mounted) {
        if (success) {
          setState(() {
            _isExpanded = true;
            _showPasteBox = false; // 붙여넣기 성공시 박스 숨기기
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ 이미지가 성공적으로 추가되었습니다.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('❌ 이미지 업로드에 실패했습니다. 형식 오류나 서버 상태를 확인해주세요.')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ 클립보드에 이미지가 없습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.vm.getImages(widget.selectedTabIndex, widget.field);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('⏳ 갤러리 이미지 업로드 중...')),
                        );
                      }
                      final success = await widget.vm.addImageToQuiz(
                          widget.selectedTabIndex, widget.field, image);
                      if (mounted) {
                        if (success) {
                          setState(() => _isExpanded = true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('✅ 이미지가 성공적으로 추가되었습니다.')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    '❌ 이미지 업로드에 실패했습니다. 형식 오류나 서버 상태를 확인해주세요.')),
                          );
                        }
                      }
                    }
                  },
                  icon: const Icon(Icons.add_photo_alternate_outlined,
                      color: primaryColor, size: 20),
                  tooltip: '이미지 추가 (갤러리)',
                ),
                IconButton(
                  onPressed: _togglePasteBox,
                  icon: Icon(Icons.paste_outlined,
                      color: _showPasteBox ? Colors.white : primaryColor,
                      size: 20),
                  tooltip: '클립보드 이미지 붙여넣기 영역 열기/닫기',
                ),
                IconButton(
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                  icon: Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.photo_library_outlined,
                    color: images.isNotEmpty ? primaryColor : Colors.white38,
                    size: 20,
                  ),
                  tooltip: '이미지 목록 펼치기/접기',
                ),
                if (images.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      '${images.length}',
                      style: const TextStyle(
                          color: primaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.keyV, control: true):
                _submitPaste,
            const SingleActivator(LogicalKeyboardKey.keyV, meta: true):
                _submitPaste,
          },
          child: Focus(
            focusNode: _focusNode,
            onFocusChange: (hasFocus) {
              if (hasFocus) setState(() {});
            },
            child: TextField(
              controller: widget.controller,
              maxLines: widget.lines,
              onChanged: widget.onChanged,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                filled: true,
                fillColor: _focusNode.hasFocus
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black26,
                hintText: _focusNode.hasFocus ? 'Ctrl+V로 이미지 붙여넣기 가능' : null,
                hintStyle: TextStyle(
                    color: primaryColor.withOpacity(0.4), fontSize: 11),
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: primaryColor, width: 1.5),
                ),
              ),
            ),
          ),
        ),
        if (_isExpanded && images.isNotEmpty) _buildImagePreview(images),
        if (_showPasteBox)
          GestureDetector(
            onTap: _submitPaste,
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: primaryColor.withOpacity(0.5),
                    width: 1.5,
                    style: BorderStyle.solid),
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
                      style: TextStyle(
                          color: primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildImagePreview(List<Map<String, dynamic>> images) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...images.asMap().entries.map((entry) {
            final index = entry.key;
            final imageUrl = entry.value['content'];

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
                          child: Image.network(
                            imageUrl,
                            // 미지정 시 기본값 BoxFit.scaleDown이 적용되어
                            // 원본 크기를 보여주되 컨테이너를 넘어가면 축소됩니다.
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => widget.vm.removeImage(
                          widget.selectedTabIndex, widget.field, index),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                            color: Colors.black87, shape: BoxShape.circle),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 16),
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
