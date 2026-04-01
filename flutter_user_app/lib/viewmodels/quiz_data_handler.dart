import 'dart:math';
import '../models/quiz_model.dart';
import '../core/api/tree_service.dart';

mixin QuizDataHandler {
  List<QuizQuestion> processQuizData(List<dynamic> data) {
    List<QuizQuestion> loadedQuestions = [];
    final random = Random();

    for (int i = 0; i < data.length; i++) {
      final tree = data[i];
      final String correctName = tree['name_kr'] as String;
      Map<String, String> hintsMap = {};
      String questionImageUrl = '';
      String? questionThumbnailUrl;

      final List<dynamic> images = tree['tree_images'] ?? [];
      for (var img in images) {
        final type = img['image_type'];
        final hint = img['hint'];
        final url = img['image_url'];
        final thumb = img['thumbnail_url'];

        if (url != null && url.isNotEmpty) {
          if (type == 'main' || questionImageUrl.isEmpty) {
            questionImageUrl = url;
            questionThumbnailUrl = thumb;
          }
        }

        String? koreanKey;
        final lowerType = type?.toString().toLowerCase() ?? '';
        
        if (lowerType == 'main' || lowerType == '전체' || lowerType == '대표' || lowerType == 'full') {
          koreanKey = '전체';
        } else if (lowerType == 'leaf' || lowerType == '잎' || lowerType == '잎새' || lowerType == 'leaves') {
          koreanKey = '잎';
        } else if (lowerType == 'bark' || lowerType == '수피' || lowerType == '나무껍질' || lowerType == 'bark_skin') {
          koreanKey = '수피';
        } else if (lowerType == 'flower' || lowerType == '꽃' || lowerType == 'blossom') {
          koreanKey = '꽃';
        } else if (lowerType == 'fruit' || lowerType == '열매' || lowerType == 'fruit_bud' || lowerType == 'winter_bud') {
          koreanKey = '열매/겨울눈';
        }

        if (koreanKey != null && hint != null && hint.toString().trim().isNotEmpty) {
          hintsMap[koreanKey] = hint.toString();
        }
      }

      List<String> options = [correctName];
      final distractorData = tree['quiz_distractors'];
      if (distractorData is List && distractorData.isNotEmpty) {
        List<String> manual = distractorData.map((e) => e.toString()).toList();
        manual.shuffle(random);
        options.addAll(manual.take(3));
      }

      if (options.length < 4) {
        final List<String> dummies = ['소나무', '느티나무', '벚나무', '단풍나무', '은행나무', '잣나무', '향나무'];
        dummies.shuffle(random);
        for (var d in dummies) {
          if (!options.contains(d)) options.add(d);
          if (options.length >= 4) break;
        }
      }

      options.shuffle(random);
      final int correctIdx = options.indexOf(correctName);

      loadedQuestions.add(QuizQuestion(
        id: tree['id'] is int ? tree['id'] : int.tryParse(tree['id'].toString()) ?? 0,
        // 450px 너비로 리사이징 요청 (성능/부하 최적화)
        imageUrl: TreeService.getProxyImageUrl(questionImageUrl, width: 450),
        thumbnailUrl: TreeService.getProxyImageUrl(questionThumbnailUrl, width: 300),
        correctAnswerIndex: correctIdx,
        options: options,
        hints: hintsMap,
        description: tree['description'] ?? '$correctName에 대한 상세 설명 정보가 없습니다.',
      ));
    }

    loadedQuestions.shuffle(random);
    return loadedQuestions;
  }

  List<QuizQuestion> getDummyQuestions() {
    return [
      QuizQuestion(
        id: 1,
        imageUrl: 'https://images.unsplash.com/photo-1542273917363-3b1817f69a2d',
        correctAnswerIndex: 0,
        options: ['소나무', '은행나무', '단풍나무', '벚나무'],
        hints: {'전체': '사계절 내내 푸른 바늘잎나무입니다.', '잎': '바늘 모양의 잎이 2개씩 뭉쳐 납니다.'},
        description: '소나무는 한국을 대표하는 나무로, 척박한 땅에서도 잘 자랍니다.',
      ),
    ];
  }
}
