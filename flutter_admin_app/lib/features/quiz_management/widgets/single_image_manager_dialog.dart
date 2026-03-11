import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:super_clipboard/super_clipboard.dart';
import '../viewmodels/quiz_extraction_step2_viewmodel.dart';
import '../../../core/widgets/fullscreen_image_viewer.dart';

class SingleQuizImageManagerDialog extends StatefulWidget {
  final QuizExtractionStep2ViewModel viewModel;
  final String field; // 'question' or 'explanation'

  const SingleQuizImageManagerDialog({
    super.key,
    required this.viewModel,
    required this.field,
  });

  @override
  State<SingleQuizImageManagerDialog> createState() =>
      _SingleQuizImageManagerDialogState();
}

class _SingleQuizImageManagerDialogState
    extends State<SingleQuizImageManagerDialog> {
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
    final reader = await SystemClipboard.instance?.read();
    if (reader == null) return;

    if (reader.canProvide(Formats.png)) {
      setState(() => _isUploading = true);
      reader.getFile(Formats.png, (file) async {
        final bytes = await file.readAll();
        final xFile = XFile.fromData(
          bytes,
          mimeType: 'image/png',
          name: 'pasted_image.png',
        );
        await _uploadImage(xFile);
      });
    } else if (reader.canProvide(Formats.jpeg)) {
      setState(() => _isUploading = true);
      reader.getFile(Formats.jpeg, (file) async {
        final bytes = await file.readAll();
        final xFile = XFile.fromData(
          bytes,
          mimeType: 'image/jpeg',
          name: 'pasted_image.jpg',
        );
        await _uploadImage(xFile);
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('?´ë¦½ë³´ë“œ???´ë?ì§€ê°€ ?†ìŠµ?ˆë‹¤.')));
      }
    }
  }

  Future<void> _uploadImage(XFile file) async {
    setState(() => _isUploading = true);
    try {
      await widget.viewModel.addImageToQuiz(widget.field, file);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('???´ë?ì§€ê°€ ?±ê³µ?ìœ¼ë¡?ì¶”ê??˜ì—ˆ?µë‹ˆ??')));
      }
    } catch (e) {
      if (mounted) {
        final errorLog = e.toString();
        String displayMsg = '?´ë?ì§€ ?…ë¡œ??ì¤??¤ë¥˜ê°€ ë°œìƒ?ˆìŠµ?ˆë‹¤.';
        if (errorLog.contains('Exception:')) {
          displayMsg = errorLog.split('Exception:').last.trim();
        } else if (errorLog.contains('ì¡°ì •?´ì„œ')) {
          displayMsg = errorLog;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('??$displayMsg'),
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
    // Current quiz blocks
    final List blocks = widget.viewModel.currentQuiz[widget.field] ?? [];
    final imageBlocks = blocks.where((b) => b['type'] == 'image').toList();

    return AlertDialog(
      backgroundColor: surfaceDark,
      title: Row(
        children: [
          const Icon(Icons.image_outlined, color: primaryColor),
          const SizedBox(width: 10),
          Text(
            '${widget.field == 'question' ? 'ë¬¸ì œ' : '?´ì„¤'} ?´ë?ì§€ ê´€ë¦?,
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
              '?„ëž˜ ?ì—­???´ë¦­?˜ì—¬ ?Œì¼??? íƒ?˜ê±°?? ?ì—­???´ë¦­(?¬ì»¤??????Ctrl+Vë¥??ŒëŸ¬ ?´ë?ì§€ë¥?ë¶™ì—¬?£ìœ¼?¸ìš”.',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 20),

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
                                  '?´ë?ì§€ ì¶”ê? ?ëŠ” Ctrl+V',
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
                                                        widget.field ==
                                                            'question'
                                                        ? 'ë¬¸ì œ ?´ë?ì§€'
                                                        : '?•ë‹µê³??´ì„¤ ?´ë?ì§€',
                                                  ),
                                            ),
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: block['content'],
                                            fit: BoxFit.contain,
                                            width: double.infinity,
                                            height: double.infinity,
                                            placeholder: (context, url) =>
                                                const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: primaryColor,
                                                        strokeWidth: 2,
                                                      ),
                                                ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () {
                                            widget.viewModel.removeImage(
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
              const Center(
                child: Column(
                  children: [
                    LinearProgressIndicator(color: primaryColor),
                    SizedBox(height: 8),
                    Text(
                      '?´ë?ì§€ ì²˜ë¦¬ ì¤?..',
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
          child: const Text('?«ê¸°', style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }
}
