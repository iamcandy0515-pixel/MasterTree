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
  final Map<String, String> imageTypes; // Map of type -> url
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
    this.imageHints = const {},
    this.displayOrder = 0,
    this.isAutoQuizEnabled = true,
  });

  factory TreeGroupMember.fromJson(Map<String, dynamic> json) {
    final treeData = json['trees'] as Map<String, dynamic>?;
    final imagesList = treeData?['tree_images'] as List<dynamic>? ?? [];

    final Map<String, String> typesMap = {};
    final Map<String, String> hintsMap = {};
    for (var img in imagesList) {
      if (img is Map) {
        final type = img['image_type']?.toString() ?? 'unknown';
        final url = img['image_url']?.toString();
        final hint = img['hint']?.toString();
        if (url != null) {
          typesMap[type] = _ensurePngForPlaceholder(url)!;
        }
        if (hint != null) {
          hintsMap[type] = hint;
        }
      }
    }

    return TreeGroupMember(
      id: json['id']?.toString(),
      treeId: (json['tree_id'] ?? '').toString(),
      treeName: treeData != null
          ? (treeData['name_kr'] ?? '알 수 없는 수목')
          : '알 수 없는 수목',
      keyCharacteristics: json['key_characteristics'] ?? '',
      imageUrl: _ensurePngForPlaceholder(
        json['image_url'] ?? _getRepresentativeImageUrl(imagesList),
      ),
      imageTypes: typesMap,
      imageHints: hintsMap,
      displayOrder: int.tryParse(json['sort_order']?.toString() ?? '0') ?? 0,
      isAutoQuizEnabled: treeData != null
          ? (treeData['is_auto_quiz_enabled'] ?? true)
          : true,
    );
  }

  String? get leafImageUrl => imageTypes['leaf'] ?? imageTypes['leaves'];
  String? get barkImageUrl => imageTypes['bark'];

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
