import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_admin_app/features/trees/viewmodels/add_tree_viewmodel.dart';
import 'package:flutter_admin_app/core/utils/web_utils.dart';
import 'package:flutter_admin_app/core/theme/neo_theme.dart';
import 'add_tree_upload_box.dart';
import 'add_tree_image_grid.dart';

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
    if (kIsWeb) _registerDropZone();
  }

  void _registerDropZone() {
    WebUtils.registerViewFactory(_dropZoneViewId, (int viewId) {
      return WebUtils.createDropZoneElement(
        onDragOver: () { if (!_isDragging) setState(() => _isDragging = true); },
        onDragLeave: () { if (_isDragging) setState(() => _isDragging = false); },
        onDrop: (files) async {
          setState(() => _isDragging = false);
          if (files != null && files.isNotEmpty && (files[0] as dynamic).type.startsWith('image/')) {
            try {
              await context.read<AddTreeViewModel>().handleDroppedFiles(files[0]);
              if (mounted) _showInfo('이미지가 수신되었습니다.');
            } catch (e) { if (mounted) _showError('업로드 실패: $e'); }
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

  void _showInfo(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  Future<void> _pickAndUploadImage(AddTreeViewModel vm) async {
    try {
      await vm.pickAndUploadImage();
      if (mounted) _showInfo('업로드 성공!');
    } catch (e) { if (mounted) _showError('업로드 실패: $e'); }
  }

  Future<void> _pasteFromClipboard(AddTreeViewModel vm) async {
    try {
      await vm.pasteImageFromClipboard();
      if (mounted) _showInfo('붙여넣기 성공!');
    } catch (e) { if (mounted) _showError('붙여넣기 실패: $e'); }
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
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('수목 이미지', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: NeoColors.acidLime)),
          const SizedBox(height: 16),
          _DropdownImageType(vm: vm, labels: _imageTypeLabels),
          const SizedBox(height: 12),
          AddTreeUploadBox(
            focusNode: _uploadBoxFocusNode,
            isDragging: _isDragging,
            dropZoneViewId: _dropZoneViewId,
            isUploading: vm.isUploading,
            onPaste: () => _pasteFromClipboard(vm),
          ),
          if (vm.uploadedImages.isNotEmpty) ...[
            const SizedBox(height: 16),
            AddTreeImageGrid(labels: _imageTypeLabels),
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
      decoration: const InputDecoration(labelText: '이미지 구분', border: InputBorder.none, labelStyle: TextStyle(color: Colors.white54)),
      dropdownColor: const Color(0xFF333333),
      items: labels.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(color: Colors.white)))).toList(),
      onChanged: (v) => vm.setSelectedImageType(v ?? 'main'),
    );
  }
}
