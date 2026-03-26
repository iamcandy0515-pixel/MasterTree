import 'tree.dart';

class CreateTreeRequest {
  final String nameKr;
  final String? nameEn;
  final String? scientificName;
  final String? description;
  final String? category;
  final int difficulty;
  final List<TreeImage> images;
  final List<String> quizDistractors;
  final bool isAutoQuizEnabled;

  CreateTreeRequest({
    required this.nameKr,
    this.nameEn,
    this.scientificName,
    this.description,
    this.category,
    this.difficulty = 1,
    this.images = const [],
    this.quizDistractors = const [],
    this.isAutoQuizEnabled = true,
  });

  Map<String, dynamic> toJson() => {
    'name_kr': nameKr,
    'name_en': nameEn,
    'scientific_name': scientificName,
    'description': description,
    'category': category,
    'difficulty': difficulty,
    'images': images.map((e) => e.toJson()).toList(),
    'quiz_distractors': quizDistractors,
    'is_auto_quiz_enabled': isAutoQuizEnabled,
  };

  CreateTreeRequest copyWith({
    String? nameKr,
    String? nameEn,
    String? scientificName,
    String? description,
    String? category,
    int? difficulty,
    List<TreeImage>? images,
    List<String>? quizDistractors,
    bool? isAutoQuizEnabled,
  }) {
    return CreateTreeRequest(
      nameKr: nameKr ?? this.nameKr,
      nameEn: nameEn ?? this.nameEn,
      scientificName: scientificName ?? this.scientificName,
      description: description ?? this.description,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      images: images ?? this.images,
      quizDistractors: quizDistractors ?? this.quizDistractors,
      isAutoQuizEnabled: isAutoQuizEnabled ?? this.isAutoQuizEnabled,
    );
  }
}
