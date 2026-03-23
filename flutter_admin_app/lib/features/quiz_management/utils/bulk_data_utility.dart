class BulkDataUtility {
  /// Updates block-based content (question or explanation)
  static Map<String, dynamic> updateBlockContent(
    Map<String, dynamic> item,
    String field,
    String value,
  ) {
    final newItem = Map<String, dynamic>.from(item);
    List blocks = List.from(newItem[field] ?? []);
    
    int firstTextIdx = blocks.indexWhere((b) => b['type'] == 'text');
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
    final cIdx = (newItem['correct_option_index'] as int?) ?? 0;
    
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
    
    if (field != null) {
      final blocks = (quiz[field] as List? ?? []);
      return blocks.any((b) => b is Map && b['type'] == 'image');
    }
    
    final qBlocks = (quiz['question'] as List? ?? []);
    final eBlocks = (quiz['explanation'] as List? ?? []);
    
    return qBlocks.any((b) => b is Map && b['type'] == 'image') ||
           eBlocks.any((b) => b is Map && b['type'] == 'image');
  }
}
