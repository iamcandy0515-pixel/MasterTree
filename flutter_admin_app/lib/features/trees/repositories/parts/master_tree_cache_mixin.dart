
mixin MasterTreeCacheMixin {
  static final Map<String, dynamic> _treeCache = {};
  static final Map<String, DateTime> _cacheExpiries = {};
  static const Duration _defaultTTL = Duration(minutes: 5);

  /// 캐시 키 생성 (페이지, 검색어, 카테고리 조합)
  String generateCacheKey(int page, int limit, String? search, String? category) {
    return 'trees_p${page}_l${limit}_s${search ?? ''}_c${category ?? ''}';
  }

  /// 캐시 데이터 조회
  T? getCachedData<T>(String key) {
    final expiry = _cacheExpiries[key];
    if (expiry != null && DateTime.now().isBefore(expiry)) {
      return _treeCache[key] as T?;
    }
    _treeCache.remove(key);
    _cacheExpiries.remove(key);
    return null;
  }

  /// 캐시 데이터 저장
  void setCachedData(String key, dynamic data, {Duration? ttl}) {
    _treeCache[key] = data;
    _cacheExpiries[key] = DateTime.now().add(ttl ?? _defaultTTL);
  }

  /// 전체 캐시 무효화 (수정/삭제 발생 시 호출)
  void invalidateTreeCache() {
    _treeCache.clear();
    _cacheExpiries.clear();
  }
}
