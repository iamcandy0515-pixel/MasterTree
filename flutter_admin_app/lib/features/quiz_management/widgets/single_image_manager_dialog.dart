import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../viewmodels/quiz_extraction_step2_viewmodel.dart';
import './image_thumbnail_list.dart';
import './image_upload_drop_zone.dart';

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
  final FocusNode _focusNode = FocusNode();
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

  Future<void> _handleImageTask(Uint8List bytes, String name) async {
    try {
      await widget.viewModel.addImageToQuiz(widget.field, bytes, name);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('새 이미지가 성공적으로 추가되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🚩 ${e.toString().split('Exception:').last.trim()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _handleXFile(XFile? file) async {
    if (file == null) return;
    final bytes = await file.readAsBytes();
    await _handleImageTask(bytes, file.name);
  }

  @override
  Widget build(BuildContext context) {
    final List blocks = widget.viewModel.extractedBlock?[widget.field] ?? [];

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
              '아래 영역을 클릭하여 파일을 선택하거나, 영역을 클릭(포커스) 후 Ctrl+V를 눌러 이미지를 붙여넣으세요.',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 20),

            Focus(
              focusNode: _focusNode,
              child: ImageUploadDropZone(
                isFocused: _isFocused,
                isLoading: widget.viewModel.isLoading,
                onPickImage: () async {
                  _focusNode.requestFocus();
                  final picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  await _handleXFile(image);
                },
                onPasteImage: _handleImageTask,
              ),
            ),

            const SizedBox(height: 16),
            ImageThumbnailList(
              blocks: blocks,
              field: widget.field,
              onRemove: (idx) {
                widget.viewModel.removeImage(widget.field, idx);
                setState(() {});
              },
            ),

            if (widget.viewModel.isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
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
