import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:flutter_admin_app/features/quiz_management/viewmodels/bulk_extraction_viewmodel.dart';
import 'image_manager/image_manager_header.dart';
import 'image_manager/image_upload_zone.dart';
import 'image_manager/image_horizontal_list.dart';
import 'image_manager/image_manager_loading.dart';

/// 문제 및 해설의 이미지를 관리하는 다이얼로그 (Refactored)
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

  static const surfaceDark = Color(0xFF1A2E24);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
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
    final imageBytes = await Pasteboard.image;
    if (imageBytes != null) {
      final fileName = 'pasted_image_${DateTime.now().millisecondsSinceEpoch}.png';
      final success = await widget.viewModel.addImageBytesToQuiz(widget.qNum, widget.field, imageBytes, fileName);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ 이미지가 성공적으로 붙여넣기 되었습니다.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❌ 클립보드 이미지 추가에 실패했습니다.')),
          );
        }
      }
    }
  }

  Future<void> _uploadImage(XFile file) async {
    if (!mounted) return;
    setState(() => _isUploading = true);
    try {
      await widget.viewModel.addImageToQuiz(widget.qNum, widget.field, file);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 이미지가 성공적으로 추가되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().split('Exception:').last.trim();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $errorMsg'),
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
    final dynamic data = quiz?[widget.field];
    final List<dynamic> blocks = data is List ? List<dynamic>.from(data as Iterable) : <dynamic>[];
    final imageBlocks = blocks.where((dynamic b) => b is Map && b['type'] == 'image').toList();

    return AlertDialog(
      backgroundColor: surfaceDark,
      title: ImageManagerHeader(field: widget.field),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '영역을 클릭하여 파일을 선택하거나, 영역 클릭 후 Ctrl+V를 눌러 이미지를 붙여넣으세요.',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 20),
            Stack(
              children: [
                ImageUploadZone(
                  onPickImage: _pickImage,
                  onPaste: _handlePaste,
                  focusNode: _focusNode,
                  isFocused: _isFocused,
                  isEmpty: imageBlocks.isEmpty,
                ),
                if (imageBlocks.isNotEmpty)
                  ImageHorizontalList(
                    viewModel: widget.viewModel,
                    qNum: widget.qNum,
                    field: widget.field,
                    imageBlocks: imageBlocks,
                    allBlocks: blocks,
                    onStateChange: () => setState(() {}),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ImageManagerLoading(isUploading: _isUploading),
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
