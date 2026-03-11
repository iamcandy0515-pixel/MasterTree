class TreeImage {
  final int? id;
  final String imageType; // 'leaf', 'bark', etc.
  final String imageUrl;
  final String? thumbnailUrl;
  final String? hint; // Quiz answer hint
  final bool isQuizEnabled; // Quiz activation toggle

  TreeImage({
    this.id,
    required this.imageType,
    required this.imageUrl,
    this.thumbnailUrl,
    this.hint,
    this.isQuizEnabled = true,
  });

  factory TreeImage.fromJson(Map<String, dynamic> json) {
    return TreeImage(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      imageType: json['image_type'] ?? '',
      imageUrl: json['image_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'],
      hint: json['hint'],
      isQuizEnabled: json['is_quiz_enabled'] ?? true,
    );
  }

  TreeImage copyWith({
    int? id,
    String? imageType,
    String? imageUrl,
    String? thumbnailUrl,
    String? hint,
    bool? isQuizEnabled,
  }) {
    return TreeImage(
      id: id ?? this.id,
      imageType: imageType ?? this.imageType,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      hint: hint ?? this.hint,
      isQuizEnabled: isQuizEnabled ?? this.isQuizEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'image_type': imageType,
    'image_url': imageUrl,
    'thumbnail_url': thumbnailUrl,
    'hint': hint,
    'is_quiz_enabled': isQuizEnabled,
  };
}

class Tree {
  final int id;
  final String nameKr;
  final String? nameEn;
  final String? scientificName;
  final String? description;
  final String? category;
  final int difficulty;
  final List<TreeImage> images;
  final List<String> quizDistractors;
  final bool isAutoQuizEnabled;

  Tree({
    required this.id,
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

  String? get imageUrl => images.isNotEmpty ? images.first.imageUrl : null;
  List<String>? get imageUrls => images.map((e) => e.imageUrl).toList();

  Tree copyWith({
    int? id,
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
    return Tree(
      id: id ?? this.id,
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

  factory Tree.fromJson(Map<String, dynamic> json) {
    return Tree(
      id: int.parse(json['id'].toString()),
      nameKr: json['name_kr'],
      nameEn: json['name_en'],
      scientificName: json['scientific_name'],
      description: json['description'],
      category: json['category'],
      difficulty: json['difficulty'] ?? 1,
      images:
          (json['tree_images'] as List<dynamic>?)
              ?.map((e) => TreeImage.fromJson(e))
              .toList() ??
          [],
      quizDistractors:
          (json['quiz_distractors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isAutoQuizEnabled: json['is_auto_quiz_enabled'] ?? true,
    );
  }
}

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
