import 'package:flutter_admin_app/core/api/node_api.dart';

class TreeGroup {
  final String id;
  final String name;
  final String description;
  final List<TreeGroupMember> members;

  TreeGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.members,
  });

  factory TreeGroup.fromJson(Map<String, dynamic> json) {
    return TreeGroup(
      id: json['id']?.toString() ?? '',
      name: json['group_name'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      members:
          (json['tree_group_members'] as List<dynamic>?)
              ?.map((e) => TreeGroupMember.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'group_name': name,
    'description': description,
  };
}

class TreeGroupMember {
  final String? id;
  final String treeId;
  final String treeName;
  final String keyCharacteristics;
  final String? imageUrl; // Representative/Main image
  final Map<String, String> imageTypes; // Map of type -> raw_url
  final Map<String, String> thumbnailTypes; // Map of type -> thumbnail_url
  final Map<String, String> imageHints; // Map of type -> hint
  final int displayOrder;
  final bool isAutoQuizEnabled; // Is standard 78 tree (quiz target)

  TreeGroupMember({
    this.id,
    required this.treeId,
    required this.treeName,
    required this.keyCharacteristics,
    this.imageUrl,
    this.imageTypes = const {},
    this.thumbnailTypes = const {},
    this.imageHints = const {},
    this.displayOrder = 0,
    this.isAutoQuizEnabled = true,
  });

  static const Map<String, String> _typeMapping = {
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

  factory TreeGroupMember.fromJson(Map<String, dynamic> json) {
    final treeData = json['trees'] as Map<String, dynamic>?;
    final imagesList = treeData?['tree_images'] as List<dynamic>? ?? [];

    final Map<String, String> typesMap = {};
    final Map<String, String> thumbMap = {};
    final Map<String, String> hintsMap = {};
    for (var img in imagesList) {
      if (img is Map) {
        final rawType = (img['image_type']?.toString() ?? 'unknown').toLowerCase().trim();
        final type = _typeMapping[rawType] ?? rawType;
        final url = img['image_url']?.toString();
        final thumb = img['thumbnail_url']?.toString();
        final hint = img['hint']?.toString();

        if (url != null) {
          typesMap[type] = _ensurePngForPlaceholder(url)!;
        }
        if (thumb != null) {
          thumbMap[type] = _ensurePngForPlaceholder(thumb)!;
        }
        if (hint != null) {
          hintsMap[type] = hint;
        }
      }
    }

    final String? rawRepUrl = json['image_url'] ?? _getRepresentativeImageUrl(imagesList);
    final repUrl = _ensurePngForPlaceholder(rawRepUrl);

    return TreeGroupMember(
      id: json['id']?.toString(),
      treeId: (json['tree_id'] ?? '').toString(),
      treeName: treeData != null
          ? (treeData['name_kr'] ?? '알 수 없는 수목')
          : '알 수 없는 수목',
      keyCharacteristics: json['key_characteristics'] ?? '',
      imageUrl: repUrl, // Raw URL (handled by UI)
      imageTypes: typesMap,
      thumbnailTypes: thumbMap,
      imageHints: hintsMap,
      displayOrder: int.tryParse(json['sort_order']?.toString() ?? '0') ?? 0,
      isAutoQuizEnabled: treeData != null
          ? (treeData['is_auto_quiz_enabled'] ?? true)
          : true,
    );
  }

  String? get leafImageUrl => imageTypes['leaf'] ?? imageTypes['leaves'] ?? imageTypes['잎'];
  String? get leafThumbnailUrl => thumbnailTypes['leaf'] ?? thumbnailTypes['leaves'] ?? thumbnailTypes['잎'];

  String? get barkImageUrl => imageTypes['bark'] ?? imageTypes['수피'];
  String? get barkThumbnailUrl => thumbnailTypes['bark'] ?? thumbnailTypes['수피'];

  String? get flowerImageUrl => imageTypes['flower'] ?? imageTypes['꽃'];
  String? get flowerThumbnailUrl => thumbnailTypes['flower'] ?? thumbnailTypes['꽃'];

  String? get fruitImageUrl => imageTypes['fruit'] ?? imageTypes['열매'];
  String? get fruitThumbnailUrl => thumbnailTypes['fruit'] ?? thumbnailTypes['열매'];

  static String? _ensurePngForPlaceholder(String? url) {
    if (url != null && url.contains('placehold.co') && !url.contains('.png')) {
      if (url.contains('?')) {
        final parts = url.split('?');
        return '${parts[0]}.png?${parts[1]}';
      }
      return '$url.png';
    }
    return url;
  }

  static String? _getRepresentativeImageUrl(List<dynamic> images) {
    if (images.isNotEmpty) {
      for (var img in images) {
        if (img is Map && img['image_type'] == 'main') {
          return img['image_url'];
        }
      }
      return images[0]['image_url'];
    }
    return null;
  }

  Map<String, dynamic> toJson(String groupId) => {
    'group_id': groupId,
    'tree_id': int.tryParse(treeId) ?? 0,
    'key_characteristics': keyCharacteristics,
    'sort_order': displayOrder,
  };
}
