import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_admin_app/core/utils/web_utils.dart';
import 'package:flutter_admin_app/core/api/node_api.dart';
import 'package:flutter_admin_app/features/trees/models/tree.dart';
import 'package:flutter_admin_app/features/trees/repositories/master_tree_media_repository.dart';

mixin TreeMediaMixin on ChangeNotifier {
  final MasterTreeMediaRepository _mediaRepo = MasterTreeMediaRepository();

  final List<TreeImage> _uploadedImages = <TreeImage>[];
  bool _isUploading = false;
  String _selectedImageType = 'main';

  List<TreeImage> get uploadedImages => _uploadedImages;
  bool get isUploading => _isUploading;
  String get selectedImageType => _selectedImageType;

  void setSelectedImageType(String value) {
    _selectedImageType = value;
    notifyListeners();
  }

  void removeImage(int index) {
    if (index >= 0 && index < _uploadedImages.length) {
      _uploadedImages.removeAt(index);
      notifyListeners();
    }
  }

  void updateImageHint(int index, String hint) {
    if (index >= 0 && index < _uploadedImages.length) {
      _uploadedImages[index] = _uploadedImages[index].copyWith(hint: hint);
      notifyListeners();
    }
  }

  void clearImages() {
    _uploadedImages.clear();
    _selectedImageType = 'main';
    notifyListeners();
  }

  void initializeImages(List<TreeImage> images) {
    _uploadedImages.clear();
    _uploadedImages.addAll(images);
    notifyListeners();
  }

  Future<void> handleDroppedFiles(dynamic file) async {
    try {
      _isUploading = true;
      notifyListeners();

      final Uint8List? bytes = await WebUtils.readFileAsBytes(file);
      if (bytes == null) throw Exception('파일을 읽을 수 없습니다.');

      final String publicUrl = await _mediaRepo.uploadImageFromBytes(
        bytes,
        kIsWeb ? (file as dynamic).name.toString() : 'dropped_file',
      );

      _uploadedImages.add(
        TreeImage(
          imageType: _selectedImageType,
          imageUrl: NodeApi.getProxyImageUrl(publicUrl),
          originUrl: publicUrl,
        ),
      );
      _isUploading = false;
      notifyListeners();
    } catch (e) {
      _isUploading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> pickAndUploadImage() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final PlatformFile file = result.files.first;
      if (file.bytes == null) return;

      _isUploading = true;
      notifyListeners();

      final String publicUrl = await _mediaRepo.uploadImageFromBytes(
        file.bytes!,
        file.name,
      );

      _uploadedImages.add(
        TreeImage(
          imageType: _selectedImageType,
          imageUrl: NodeApi.getProxyImageUrl(publicUrl),
          originUrl: publicUrl,
        ),
      );
      _isUploading = false;
      notifyListeners();
    } catch (e) {
      _isUploading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> pasteImageFromClipboard() async {
    if (!kIsWeb) {
      throw Exception('모바일에서는 클립보드 붙여넣기가 지원되지 않습니다.');
    }

    try {
      _isUploading = true;
      notifyListeners();

      bool imageFound = false;
      await WebUtils.pasteImageFromClipboard((List<int> bytes, String name, String type) async {
        final String publicUrl = await _mediaRepo.uploadImageFromBytes(
          Uint8List.fromList(bytes),
          name,
        );

      _uploadedImages.add(
        TreeImage(
          imageType: _selectedImageType,
          imageUrl: NodeApi.getProxyImageUrl(publicUrl),
          originUrl: publicUrl,
        ),
      );
        imageFound = true;
        notifyListeners();
      });

      _isUploading = false;
      notifyListeners();
      if (!imageFound) throw Exception('클립보드에 이미지가 없습니다.');
    } catch (e) {
      _isUploading = false;
      notifyListeners();
      rethrow;
    }
  }
}
