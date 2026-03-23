import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_admin_app/core/utils/web_utils.dart';
import 'package:flutter_admin_app/features/trees/models/tree.dart';
import 'package:flutter_admin_app/features/trees/repositories/master_tree_media_repository.dart';

mixin TreeMediaMixin on ChangeNotifier {
  final MasterTreeMediaRepository _mediaRepo = MasterTreeMediaRepository();

  final List<TreeImage> _uploadedImages = [];
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
    _uploadedImages.removeAt(index);
    notifyListeners();
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

      final bytes = await WebUtils.readFileAsBytes(file);
      if (bytes == null) throw Exception('파일을 읽을 수 없습니다.');

      final publicUrl = await _mediaRepo.uploadImageFromBytes(
        Uint8List.fromList(bytes),
        kIsWeb ? (file as dynamic).name : 'dropped_file',
      );

      _uploadedImages.add(
        TreeImage(imageType: _selectedImageType, imageUrl: publicUrl),
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
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.bytes == null) return;

      _isUploading = true;
      notifyListeners();

      final publicUrl = await _mediaRepo.uploadImageFromBytes(
        file.bytes!,
        file.name,
      );

      _uploadedImages.add(
        TreeImage(imageType: _selectedImageType, imageUrl: publicUrl),
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
      await WebUtils.pasteImageFromClipboard((bytes, name, type) async {
        final publicUrl = await _mediaRepo.uploadImageFromBytes(
          Uint8List.fromList(bytes),
          name,
        );

        _uploadedImages.add(
          TreeImage(imageType: _selectedImageType, imageUrl: publicUrl),
        );
        imageFound = true;
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
