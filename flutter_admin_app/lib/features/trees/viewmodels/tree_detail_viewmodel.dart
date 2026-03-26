import 'package:flutter/material.dart';
import 'package:flutter_admin_app/features/trees/models/tree.dart';
import 'package:flutter_admin_app/features/trees/models/create_tree_request.dart';
import 'package:flutter_admin_app/features/trees/repositories/master_tree_repository.dart';

class TreeDetailViewModel extends ChangeNotifier {
  final MasterTreeRepository _repository = MasterTreeRepository();
  final Tree tree;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  final TextEditingController descController = TextEditingController();
  final Map<String, TextEditingController> hintControllers = {
    'main': TextEditingController(),
    'bark': TextEditingController(),
    'leaf': TextEditingController(),
    'flower': TextEditingController(),
    'fruit': TextEditingController(),
  };

  TreeDetailViewModel({required this.tree}) {
    descController.text = tree.description ?? '';
    for (var img in tree.images) {
      if (hintControllers.containsKey(img.imageType)) {
        hintControllers[img.imageType]!.text = img.hint ?? '';
      }
    }
  }

  @override
  void dispose() {
    descController.dispose();
    for (var c in hintControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> saveHints(BuildContext context) async {
    _isSaving = true;
    notifyListeners();

    try {
      // Create updated images array
      List<TreeImage> updatedImages = tree.images.map((img) {
        String? newHint = hintControllers[img.imageType]?.text;
        return img.copyWith(hint: newHint ?? img.hint);
      }).toList();

      final request = CreateTreeRequest(
        nameKr: tree.nameKr,
        scientificName: tree.scientificName,
        description: descController.text,
        category: tree.category,
        difficulty: tree.difficulty,
        quizDistractors: tree.quizDistractors,
        isAutoQuizEnabled: tree.isAutoQuizEnabled,
        images: updatedImages,
      );

      await _repository.updateTree(tree.id, request);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('힌트가 성공적으로 저장되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
