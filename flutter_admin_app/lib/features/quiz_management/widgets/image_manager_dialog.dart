import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../viewmodels/bulk_extraction_viewmodel.dart';
import '../../../core/widgets/fullscreen_image_viewer.dart';

class ImageManagerDialog extends StatefulWidget {
  final BulkExtractionViewModel viewModel;
  final int qNum;
  final String field; // 'question' or 'explanation'

  const ImageManagerDialog({
    super.key,
    required this.viewModel,
    required this.qNum,
    required this.field,
  });

  @override
  State<ImageManagerDialog> createState() => _ImageManagerDialogState();
}

class _ImageManagerDialogState extends State<ImageManagerDialog> {
  final ImagePicker _picker = ImagePicker();
  final FocusNode _focusNode = FocusNode();
  bool _isUploading = false;
  bool _isFocused = false;

  static const primaryColor = Color(0xFF2BEE8C);
  static const surfaceDark = Color(0xFF1A2E24);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _uploadImage(image);
    }
  }

  Future<void> _handlePaste() async {
    // Disabled temporarily to fix build issues
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('붙여넣기 기능이 현재 비활성화되어 있습니다.')),
    );
  }

  Future<void> _uploadImage(XFile file) async {
    setState(() => _isUploading = true);
    try {
      await widget.viewModel.addImageToQuiz(widget.qNum, widget.field, file);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('✅ 이미지가 성공적으로 추가되었습니다.')));
      }
    } catch (e) {
      if (mounted) {
        // Exception: 메시지 형태에서 메시지만 추출
        final errorLog = e.toString();
        String displayMsg = '이미지 업로드 중 오류가 발생했습니다.';

        if (errorLog.contains('Exception:')) {
          displayMsg = errorLog.split('Exception:').last.trim();
        } else if (errorLog.contains('조정해서')) {
          displayMsg = errorLog;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $displayMsg'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final quiz = widget.viewModel.extractedQuizzes[widget.qNum];
    final List blocks = quiz?[widget.field] ?? [];
    final imageBlocks = blocks.where((b) => b['type'] == 'image').toList();

    return AlertDialog(
      backgroundColor: surfaceDark,
      title: Row(
        children: [
          const Icon(Icons.image_outlined, color: primaryColor),
          const SizedBox(width: 10),
          Text(
            '${widget.field == 'question' ? '문제' : '해설'} 이미지 관리',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '아래 영역을 클릭하여 파일을 선택하거나, 영역을 클릭(포커스)한 후 Ctrl+V를 눌러 이미지를 붙여넣으세요.',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 20),

            // 이미지 리스트 및 업로드 영역
            GestureDetector(
              onTap: () {
                _focusNode.requestFocus();
                _pickImage();
              },
              child: CallbackShortcuts(
                bindings: {
                  const SingleActivator(LogicalKeyboardKey.keyV, control: true):
                      _handlePaste,
                },
                child: Focus(
                  focusNode: _focusNode,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isFocused ? primaryColor : Colors.white10,
                        width: _isFocused ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        if (imageBlocks.isEmpty)
                          Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: _isFocused
                                      ? primaryColor
                                      : Colors.white24,
                                  size: 48,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '이미지 추가 또는 Ctrl+V',
                                  style: TextStyle(
                                    color: _isFocused
                                        ? primaryColor
                                        : Colors.white24,
                                    fontWeight: _isFocused
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          SizedBox(
                            height: 180,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: imageBlocks.length,
                              itemBuilder: (context, index) {
                                final block = imageBlocks[index];
                                final realIndex = blocks.indexOf(block);
                                return Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  width: 140,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.white10),
                                  ),
                                  child: Stack(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  FullscreenImageViewer(
                                                    imageUrl: block['content'],
                                                    title:
                                                        '${widget.field == 'question' ? '문제' : '해설'} 이미지',
                                                  ),
                                            ),
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: block['content'],
                                            fit: BoxFit.contain,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () {
                                            widget.viewModel.removeImage(
                                              widget.qNum,
                                              widget.field,
                                              realIndex,
                                            );
                                            setState(() {});
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            if (_isUploading)
              Center(
                child: Column(
                  children: const [
                    LinearProgressIndicator(color: primaryColor),
                    SizedBox(height: 8),
                    Text(
                      '이미지 처리 중...',
                      style: TextStyle(color: primaryColor, fontSize: 11),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기', style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }
}
