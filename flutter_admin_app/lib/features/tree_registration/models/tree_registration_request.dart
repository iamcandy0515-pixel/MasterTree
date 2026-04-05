import 'package:flutter_admin_app/features/trees/models/tree.dart';

class TreeRegistrationRequest {
  final String nameKr;
  final String? scientificName;
  final String? category;
  final String? description;
  final String habit; // '상록수' | '낙엽수'
  final List<TreeImage> images;
  final List<String> quizDistractors;
  final bool isAutoQuizEnabled;

  TreeRegistrationRequest({
    required this.nameKr,
    this.scientificName,
    this.category,
    this.description,
    required this.habit,
    this.images = const <TreeImage>[],
    this.quizDistractors = const <String>[],
    this.isAutoQuizEnabled = true,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name_kr': nameKr,
    'scientific_name': scientificName,
    'category': category,
    'description': description,
    'habit': habit,
    'images': images.map((TreeImage e) => e.toJson()).toList(),
    'quiz_distractors': quizDistractors,
    'is_auto_quiz_enabled': isAutoQuizEnabled,
  };
}
