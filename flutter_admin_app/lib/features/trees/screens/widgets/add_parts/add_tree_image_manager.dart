import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/add_tree_viewmodel.dart';
import 'package:flutter_admin_app/core/utils/web_utils.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';

class AddTreeImageManager extends StatefulWidget {
  const AddTreeImageManager({super.key});

  @override
  State<AddTreeImageManager> createState() => _AddTreeImageManagerState();
}

class _AddTreeImageManagerState extends State<AddTreeImageManager> {
  final FocusNode _uploadBoxFocusNode = FocusNode();
  bool _isDragging = false;
  late String _dropZoneViewId;

  final Map<String, String> _imageTypeLabels = {
    'main': '대표 사진',
    'leaf': '잎',
    'bark': '나무껍질(수피)',
    'flower': '꽃',
    'fruit': '열매/겨울눈',
    'full': '전체 전경',
  };

  @override
  void initState() {
    super.initState();
    _dropZoneViewId = 'upload-drop-zone-${DateTime.now().millisecondsSinceEpoch}';

    if (kIsWeb) {
      _registerDropZone();
    }
  }

  void _registerDropZone() {
    WebUtils.registerViewFactory(_dropZoneViewId, (int viewId) {
      return WebUtils.createDropZoneElement(
        onDragOver: () {
          if (!_isDragging) setState(() => _isDragging = true);
        },
        onDragLeave: () {
          if (_isDragging) setState(() => _isDragging = false);
        },
        onDrop: (files) async {
          setState(() => _isDragging = false);
          if (files != null && files.isNotEmpty) {
            final file = files[0];
            if ((file as dynamic).type.startsWith('image/')) {
              try {
                await context.read<AddTreeViewModel>().handleDroppedFiles(file);
                if (mounted) _showSuccess('이미지가 수신되었습니다.');
              } catch (e) {
                if (mounted) _showError('업로드 실패: $e');
              }
            }
          }
        },
        onClick: () {
          _uploadBoxFocusNode.requestFocus();
          final vm = context.read<AddTreeViewModel>();
          if (!vm.isUploading) _pickAndUploadImage(vm);
        },
      );
    });
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  Future<void> _pickAndUploadImage(AddTreeViewModel vm) async {
    try {
      await vm.pickAndUploadImage();
      if (mounted) _showSuccess('이미지가 업로드되었습니다.');
    } catch (e) {
      if (mounted) _showError('업로드 실패: $e');
    }
  }

  Future<void> _pasteFromClipboard(AddTreeViewModel vm) async {
    try {
      await vm.pasteImageFromClipboard();
      if (mounted) _showSuccess('클립보드 이미지가 업로드되었습니다.');
    } catch (e) {
      if (mounted) _showError('붙여넣기 실패: $e');
    }
  }

  @override
  void dispose() {
    _uploadBoxFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddTreeViewModel>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '수목 이미지',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: NeoColors.acidLime,
            ),
          ),
          const SizedBox(height: 16),
          _DropdownImageType(vm: vm, labels: _imageTypeLabels),
          const SizedBox(height: 12),
          _UploadBox(
            focusNode: _uploadBoxFocusNode,
            isDragging: _isDragging,
            dropZoneViewId: _dropZoneViewId,
            isUploading: vm.isUploading,
            onPaste: () => _pasteFromClipboard(vm),
          ),
          if (vm.uploadedImages.isNotEmpty) ...[
            const SizedBox(height: 16),
            _ImageGrid(vm: vm, labels: _imageTypeLabels),
          ],
        ],
      ),
    );
  }
}

class _DropdownImageType extends StatelessWidget {
  final AddTreeViewModel vm;
  final Map<String, String> labels;
  const _DropdownImageType({required this.vm, required this.labels});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: vm.selectedImageType,
      decoration: const InputDecoration(
        labelText: '이미지 구분',
        border: InputBorder.none,
        labelStyle: TextStyle(color: Colors.white54),
      ),
      dropdownColor: const Color(0xFF333333),
      items: labels.entries
          .map((e) => DropdownMenuItem(
                value: e.key,
                child: Text(e.value, style: const TextStyle(color: Colors.white)),
              ))
          .toList(),
      onChanged: (v) => vm.setSelectedImageType(v ?? 'main'),
    );
  }
}

class _UploadBox extends StatelessWidget {
  final FocusNode focusNode;
  final bool isDragging;
  final String dropZoneViewId;
  final bool isUploading;
  final VoidCallback onPaste;

  const _UploadBox({
    required this.focusNode,
    required this.isDragging,
    required this.dropZoneViewId,
    required this.isUploading,
    required this.onPaste,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            final isCtrlPressed = HardwareKeyboard.instance.isControlPressed;
            final isCmdPressed = HardwareKeyboard.instance.isMetaPressed;
            final isVPressed = event.logicalKey == LogicalKeyboardKey.keyV;
            if ((isCtrlPressed || isCmdPressed) && isVPressed) {
              onPaste();
            }
          }
        },
        child: Stack(
          children: [
            if (kIsWeb)
              SizedBox(
                height: 100,
                child: HtmlElementView(viewType: dropZoneViewId),
              ),
            IgnorePointer(
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDragging || focusNode.hasFocus ? NeoColors.acidLime : Colors.white10,
                    width: isDragging || focusNode.hasFocus ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: isDragging || focusNode.hasFocus
                      ? NeoColors.acidLime.withValues(alpha: 0.05)
                      : Colors.white.withValues(alpha: 0.02),
                ),
                child: isUploading
                    ? const Center(child: CircularProgressIndicator(color: NeoColors.acidLime))
                    : Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              color: isDragging ? NeoColors.acidLime : Colors.white38,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isDragging ? '여기에 놓으세요' : '클릭/드래그/붙여넣기 업로드',
                              style: const TextStyle(color: Colors.white38, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageGrid extends StatelessWidget {
  final AddTreeViewModel vm;
  final Map<String, String> labels;
  const _ImageGrid({required this.vm, required this.labels});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: vm.uploadedImages.length,
      itemBuilder: (context, index) {
        final img = vm.uploadedImages[index];
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(img.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => vm.removeImage(index),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                color: Colors.black54,
                child: Text(
                  labels[img.imageType] ?? img.imageType,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
