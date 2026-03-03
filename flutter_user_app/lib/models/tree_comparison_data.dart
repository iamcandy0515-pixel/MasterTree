class TreeComparisonData {
  final String leafHint;
  final String barkHint;
  final String etcHint;
  final String? mainImageUrl;
  final String? leafImageUrl;
  final String? barkImageUrl;
  final String? flowerImageUrl;
  final String? fruitImageUrl;

  TreeComparisonData({
    required this.leafHint,
    required this.barkHint,
    required this.etcHint,
    this.mainImageUrl,
    this.leafImageUrl,
    this.barkImageUrl,
    this.flowerImageUrl,
    this.fruitImageUrl,
  });

  factory TreeComparisonData.empty() => TreeComparisonData(
    leafHint: '정보가 없습니다.',
    barkHint: '정보가 없습니다.',
    etcHint: '정보가 없습니다.',
  );
}
