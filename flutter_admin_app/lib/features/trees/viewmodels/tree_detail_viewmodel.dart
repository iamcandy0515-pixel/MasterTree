import 'package:flutter/material.dart';
import 'package:flutter_admin_app/features/trees/models/tree.dart';
import 'package:flutter_admin_app/features/trees/models/create_tree_request.dart';
import 'package:flutter_admin_app/features/trees/repositories/master_tree_repository.dart';

class TreeDetailViewModel extends ChangeNotifier {
  final MasterTreeRepository _repository = MasterTreeRepository();
  Tree tree;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  final TextEditingController descController = TextEditingController();
  final Map<String, TextEditingController> hintControllers = <String, TextEditingController>{
    'main': TextEditingController(),
    'bark': TextEditingController(),
    'leaf': TextEditingController(),
    'flower': TextEditingController(),
    'fruit': TextEditingController(),
  };

  TreeDetailViewModel({required this.tree}) {
    _initControllers();
  }

  Future<void> fetchDetails() async {
    _isLoading = true;
    notifyListeners();

    try {
      final Tree detailedTree = await _repository.getTreeById(tree.id);
      tree = detailedTree;
      _initControllers();
    } catch (e) {
      debugPrint('[TreeDetailViewModel] fetchDetails failed: ');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _initControllers() {
    descController.text = tree.description ?? '';
    // Clear first to avoid duplication
    hintControllers.forEach((String _, TextEditingController c) => c.text = '');
    
    // Sort to prioritize records with actual hints
    final List<TreeImage> sortedImages = List<TreeImage>.from(tree.images)
      ..sort((TreeImage a, TreeImage b) => (b.hint?.length ?? 0).compareTo(a.hint?.length ?? 0));

    for (final TreeImage img in sortedImages) {
      if (hintControllers.containsKey(img.imageType)) {
        if (img.hint != null && img.hint!.isNotEmpty && (hintControllers[img.imageType]?.text.isEmpty ?? true)) {
          hintControllers[img.imageType]!.text = img.hint!;
        }
      }
    }
  }

  @override
  void dispose() {
    descController.dispose();
    for (final TextEditingController c in hintControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> saveHints(BuildContext context) async {
    _isSaving = true;
    notifyListeners();

    try {
      final List<TreeImage> finalImages = <TreeImage>[];
      final List<String> categories = <String>['main', 'leaf', 'bark', 'flower', 'fruit'];
      
      for (final String cat in categories) {
        final String hint = hintControllers[cat]?.text ?? '';
        final List<TreeImage> existing = tree.images.where((TreeImage i) => i.imageType == cat).toList();
        
        if (existing.isNotEmpty) {
          // Update all existing images of this type with the same hint
          finalImages.addAll(existing.map((TreeImage i) => i.copyWith(hint: hint)));
        } else if (hint.isNotEmpty) {
          // Create a new "hint-only" record with null imageUrl
          finalImages.add(TreeImage(
            imageType: cat,
            imageUrl: '', // Will be mapped to null in toJson()
            hint: hint,
            isQuizEnabled: false,
          ));
        }
      }
      
      // Preserve images from other categories
      Iterable<TreeImage> finalOtherImages() {
        return tree.images.where((TreeImage i) => !categories.contains(i.imageType));
      }
      finalImages.addAll(finalOtherImages());

      final CreateTreeRequest request = CreateTreeRequest(
        nameKr: tree.nameKr,
        nameEn: tree.nameEn,
        scientificName: tree.scientificName,
        description: descController.text,
        category: tree.category,
        difficulty: tree.difficulty,
        quizDistractors: tree.quizDistractors,
        isAutoQuizEnabled: tree.isAutoQuizEnabled,
        images: finalImages,
      );

      final Tree updated = await _repository.updateTree(tree.id, request);
      
      // Sync local state
      tree = updated;
      _initControllers(); // Re-sync controllers with backend data

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
          SnackBar(content: Text('저장 실패: '), backgroundColor: Colors.red),
        );
      }
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
