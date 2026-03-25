class BulkDataUtility {
  /// Updates block-based content (question or explanation)
  static Map<String, dynamic> updateBlockContent(
    Map<String, dynamic> item,
    String field,
    String value,
  ) {
    final newItem = Map<String, dynamic>.from(item);
    
    final data = newItem[field];
    List blocks;
    if (data is List) {
      blocks = List.from(data);
    } else if (data is String && data.isNotEmpty) {
      blocks = [{'type': 'text', 'content': data}];
    } else {
      blocks = [];
    }
    
    int firstTextIdx = blocks.indexWhere((b) => b is Map && b['type'] == 'text');
    final newBlock = {'type': 'text', 'content': value};

    if (firstTextIdx >= 0) {
      // Replace existing text blocks with a single new one (or merge/manage)
      // Standard rule: clear all text blocks and put one, or replace the first one.
      // Current implementation in original: remove all text blocks, insert one.
      blocks.removeWhere((b) => b['type'] == 'text');
      blocks.insert(firstTextIdx.clamp(0, blocks.length), newBlock);
    } else {
      blocks.insert(0, newBlock);
    }
    
    newItem[field] = blocks;
    return newItem;
  }

  /// Updates wrong option for simplified 2-option quizzes
  static Map<String, dynamic> updateWrongOption(
    Map<String, dynamic> item,
    String value,
  ) {
    final newItem = Map<String, dynamic>.from(item);
    final options = List<String>.from(newItem['options'] ?? []);
    final rawIdx = newItem['correct_option_index'];
    final cIdx = rawIdx is int ? rawIdx : int.tryParse(rawIdx?.toString() ?? '0') ?? 0;
    
    if (options.length >= 2) {
      final wIdx = 1 - cIdx;
      if (wIdx >= 0 && wIdx < options.length) {
        options[wIdx] = value;
        newItem['options'] = options;
      }
    }
    return newItem;
  }

  /// Checks if a quiz contains any image blocks
  static bool hasImage(Map<int, Map<String, dynamic>> quizzes, int qNum, [String? field]) {
    if (!quizzes.containsKey(qNum)) return false;
    final quiz = quizzes[qNum]!;
    
    bool _checkBlocks(dynamic data) {
      if (data is! List) return false;
      return data.any((b) => b is Map && b['type'] == 'image');
    }

    if (field != null) {
      return _checkBlocks(quiz[field]);
    }
    
    return _checkBlocks(quiz['question']) ||
           _checkBlocks(quiz['explanation']) ||
           _checkBlocks(quiz['hint']) ||
           _checkBlocks(quiz['wrong_answer']);
  }
}
