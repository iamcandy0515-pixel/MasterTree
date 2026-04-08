import 'package:flutter_admin_app/core/api/node_api.dart';

class TreeImage {
  final int? id;
  final String imageType; // 'leaf', 'bark', etc.
  final String imageUrl; // Display URL (Proxied)
  final String? quizzSourceImageUrl; // Cloudinary optimization URL
  final String? originUrl; // Original URL (RAW)
  final String? thumbnailUrl;
  final String? hint; // Quiz answer hint
  final bool isQuizEnabled; // Quiz activation toggle

  TreeImage({
    this.id,
    required this.imageType,
    this.imageUrl = '',
    this.quizzSourceImageUrl,
    this.originUrl,
    this.thumbnailUrl,
    this.hint,
    this.isQuizEnabled = true,
  });

  static const Map<String, String> _typeMapping = <String, String>{
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
    final String rawUrl = (json['quizz_source_image_url'] ?? json['image_url'] ?? '').toString();
    final dynamic thumbUrl = json['thumbnail_url'];

    return TreeImage(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      imageType: (() {
        final String rawType = (json['image_type'] ?? '').toString().toLowerCase().trim();
        return _typeMapping[rawType] ?? rawType;
      })(),
      imageUrl: NodeApi.getProxyImageUrl(rawUrl),
      quizzSourceImageUrl: (json['quizz_source_image_url'] ?? '').toString(),
      originUrl: (json['image_url'] ?? '').toString(),
      thumbnailUrl: thumbUrl != null ? NodeApi.getProxyImageUrl(thumbUrl as String) : null,
      hint: json['hint'] as String?,
      isQuizEnabled: (json['is_quiz_enabled'] as bool?) ?? true,
    );
  }

  TreeImage copyWith({
    int? id,
    String? imageType,
    String? imageUrl,
    String? quizzSourceImageUrl,
    String? originUrl,
    String? thumbnailUrl,
    String? hint,
    bool? isQuizEnabled,
  }) {
    return TreeImage(
      id: id ?? this.id,
      imageType: imageType ?? this.imageType,
      imageUrl: imageUrl ?? this.imageUrl,
      quizzSourceImageUrl: quizzSourceImageUrl ?? this.quizzSourceImageUrl,
      originUrl: originUrl ?? this.originUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      hint: hint ?? this.hint,
      isQuizEnabled: isQuizEnabled ?? this.isQuizEnabled,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'image_type': imageType,
    'image_url': (originUrl != null && originUrl!.isNotEmpty) 
        ? originUrl 
        : (imageUrl.isNotEmpty ? imageUrl : null),
    'quizz_source_image_url': quizzSourceImageUrl,
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
    this.images = const <TreeImage>[],
    this.quizDistractors = const <String>[],
    this.isAutoQuizEnabled = true,
  });

  String? get imageUrl => images.isNotEmpty ? images.first.imageUrl : null;
  List<String> get imageUrls => images.map((TreeImage e) => e.imageUrl).toList();

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
      nameKr: (json['name_kr'] ?? '').toString(),
      nameEn: json['name_en'] as String?,
      scientificName: json['scientific_name'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      difficulty: (json['difficulty'] as int?) ?? 1,
      images:
          (json['tree_images'] as List<dynamic>?)
              ?.map((dynamic e) => TreeImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <TreeImage>[],
      quizDistractors:
          (json['quiz_distractors'] as List<dynamic>?)
              ?.map((dynamic e) => e.toString())
              .toList() ??
          <String>[],
      isAutoQuizEnabled: (json['is_auto_quiz_enabled'] as bool?) ?? true,
    );
  }
}
