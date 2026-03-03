import '../models/tree_comparison_data.dart';
import '../core/api_service.dart';

/// 수목 비교 데이터를 가공하는 비지니스 로직 프로세서
class TreeComparisonProcessor {
  /// 트리 데이터(JSON Map)를 UI용 TreeComparisonData 모델로 변환
  static TreeComparisonData processTreeData(Map<String, dynamic>? treeData) {
    if (treeData == null) return TreeComparisonData.empty();

    return TreeComparisonData(
      leafHint: _getCombinedHint(treeData, ['잎']),
      barkHint: _getCombinedHint(treeData, ['수피']),
      etcHint: _getCombinedHint(treeData, ['꽃', '열매']),
      mainImageUrl: _getImageUrl(treeData, '대표'),
      leafImageUrl: _getImageUrl(treeData, '잎'),
      barkImageUrl: _getImageUrl(treeData, '수피'),
      flowerImageUrl: _getImageUrl(treeData, '꽃'),
      fruitImageUrl: _getImageUrl(treeData, '열매'),
    );
  }

  /// 특정 태그(잎, 수피 등)에 해당하는 이미지 URL 추출 및 프록시 적용
  static String? _getImageUrl(Map<String, dynamic>? treeData, String tag) {
    if (treeData == null) return null;
    final images = treeData['tree_images'] as List<dynamic>?;
    if (images == null) return null;

    final typeMap = {
      '잎': ['leaf'],
      '수피': ['bark', 'branch', 'twig', 'stem'],
      '꽃': ['flower'],
      '열매': ['fruit', 'fruit_bud', 'winter_bud', 'bud'],
      '대표': ['main', 'representative'],
    };

    final targetTypes = typeMap[tag] ?? [];
    try {
      final img = images.firstWhere(
        (i) => targetTypes.contains(i['image_type']),
        orElse: () => null,
      );
      final String? rawUrl = img?['image_url'];
      if (rawUrl == null || rawUrl.isEmpty) return null;
      return ApiService.getProxyImageUrl(rawUrl);
    } catch (e) {
      return null;
    }
  }

  /// 여러 태그에 걸친 힌트 텍스트를 추출하여 하나로 병합
  static String _getCombinedHint(
    Map<String, dynamic>? treeData,
    List<String> tags,
  ) {
    if (treeData == null) return '정보가 없습니다.';

    final images = treeData['tree_images'] as List<dynamic>?;
    if (images == null || images.isEmpty) return '정보가 없습니다.';

    List<String> hints = [];
    final typeMap = {
      '잎': ['leaf'],
      '수피': ['bark', 'branch', 'twig', 'stem'],
      '꽃': ['flower'],
      '열매': ['fruit', 'fruit_bud', 'winter_bud', 'bud'],
      '대표': ['main', 'representative'],
    };

    final allTargetTypes = tags
        .expand((tag) => typeMap[tag] ?? <String>[])
        .toList();

    for (var img in images) {
      final imgType = img['image_type']?.toString().toLowerCase();
      final hintValue = img['hint']?.toString();

      if (imgType != null && allTargetTypes.contains(imgType)) {
        if (hintValue != null &&
            hintValue.isNotEmpty &&
            hintValue != '자료없음' &&
            !hints.contains(hintValue)) {
          hints.add(hintValue);
        }
      }
    }

    return hints.isEmpty ? '상세 정보가 없습니다.' : hints.join('\n\n');
  }
}
