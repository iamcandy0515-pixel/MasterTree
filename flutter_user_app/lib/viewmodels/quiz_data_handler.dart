import 'dart:math';
import '../models/quiz_model.dart';

mixin QuizDataHandler {
  List<QuizQuestion> processQuizData(List<dynamic> data) {
    List<QuizQuestion> loadedQuestions = [];
    final random = Random();

    for (int i = 0; i < data.length; i++) {
      final tree = data[i];
      final String correctName = tree['name_kr'] as String;
      Map<String, String> hintsMap = {};
      String questionImageUrl = '';

      final List<dynamic> images = tree['tree_images'] ?? [];
      for (var img in images) {
        final type = img['image_type'];
        final hint = img['hint'];
        final url = img['image_url'];

        if (url != null && url.isNotEmpty) {
          if (type == 'main' || questionImageUrl.isEmpty) {
            questionImageUrl = url;
          }
        }

        String? koreanKey;
        switch (type) {
          case 'main': koreanKey = '대표'; break;
          case 'leaf': koreanKey = '잎'; break;
          case 'bark': koreanKey = '수피'; break;
          case 'flower': koreanKey = '꽃'; break;
          case 'fruit': koreanKey = '열매/겨울눈'; break;
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
        imageUrl: questionImageUrl,
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
        hints: {'대표': '사계절 내내 푸른 바늘잎나무입니다.', '잎': '바늘 모양의 잎이 2개씩 뭉쳐 납니다.'},
        description: '소나무는 한국을 대표하는 나무로, 척박한 땅에서도 잘 자랍니다.',
      ),
    ];
  }
}
