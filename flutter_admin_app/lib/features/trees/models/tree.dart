import 'package:flutter_admin_app/core/api/node_api.dart';

class TreeImage {
  final int? id;
  final String imageType; // 'leaf', 'bark', etc.
  final String imageUrl; // Display URL (Proxied)
  final String? originUrl; // Original URL (RAW)
  final String? thumbnailUrl;
  final String? hint; // Quiz answer hint
  final bool isQuizEnabled; // Quiz activation toggle

  TreeImage({
    this.id,
    required this.imageType,
    this.imageUrl = '',
    this.originUrl,
    this.thumbnailUrl,
    this.hint,
    this.isQuizEnabled = true,
  });

  static const Map<String, String> _typeMapping = {
    '대표': 'main',
    '전체': 'main',
    'main': 'main',
    '잎': 'leaf',
    '잎새': 'leaf',
    'leaf': 'leaf',
    'leaves': 'leaf',
    '수피': 'bark',
    '나무껍질': 'bark',
    'bark': 'bark',
    'branch': 'bark',
    'twig': 'bark',
    'stem': 'bark',
    'bark_skin': 'bark',
    '꽃': 'flower',
    'flower': 'flower',
    'blossom': 'flower',
    '열매': 'fruit',
    'fruit': 'fruit',
    'fruit_bud': 'fruit',
    'winter_bud': 'fruit',
    'bud': 'fruit',
    'seed': 'fruit',
  };

  factory TreeImage.fromJson(Map<String, dynamic> json) {
    final rawUrl = json['image_url'] ?? '';
    final thumbUrl = json['thumbnail_url'];

    return TreeImage(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      imageType: () {
        final rawType = (json['image_type'] ?? '').toString().toLowerCase().trim();
        return _typeMapping[rawType] ?? rawType;
      }(),
      imageUrl: NodeApi.getProxyImageUrl(rawUrl),
      originUrl: rawUrl,
      thumbnailUrl: thumbUrl != null ? NodeApi.getProxyImageUrl(thumbUrl) : null,
      hint: json['hint'],
      isQuizEnabled: json['is_quiz_enabled'] ?? true,
    );
  }

  TreeImage copyWith({
    int? id,
    String? imageType,
    String? imageUrl,
    String? originUrl,
    String? thumbnailUrl,
    String? hint,
    bool? isQuizEnabled,
  }) {
    return TreeImage(
      id: id ?? this.id,
      imageType: imageType ?? this.imageType,
      imageUrl: imageUrl ?? this.imageUrl,
      originUrl: originUrl ?? this.originUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      hint: hint ?? this.hint,
      isQuizEnabled: isQuizEnabled ?? this.isQuizEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'image_type': imageType,
    'image_url': (originUrl != null && originUrl!.isNotEmpty) 
        ? originUrl 
        : (imageUrl.isNotEmpty ? imageUrl : null),
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
  List<String> get imageUrls => images.map((e) => e.imageUrl).whereType<String>().toList();

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

