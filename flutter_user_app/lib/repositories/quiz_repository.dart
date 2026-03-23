import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/quiz_model.dart';
import '../core/api/tree_service.dart';

class QuizRepository {
  static Future<List<QuizQuestion>> fetchQuestions() async {
    try {
      final trees = await TreeService.getTrees(limit: 100);
      if (trees.isEmpty) {
        debugPrint('No trees found in DB.');
        return [];
      }

      List<QuizQuestion> loadedQuestions = [];
      final random = Random();

      for (int i = 0; i < trees.length; i++) {
        final tree = trees[i];
        final String correctName = tree['name_kr'] as String;

        // 힌트 및 이미지 경로 설정
        Map<String, String> hintsMap = {};
        String questionImageUrl = 'https://via.placeholder.com/400';

        final List<dynamic> images = tree['tree_images'] ?? [];
        for (var img in images) {
          final type = img['image_type'];
          final hint = img['hint'];
          final url = img['image_url'];

          if (url != null && url.isNotEmpty) {
            if (type == 'main' || questionImageUrl.contains('placeholder')) {
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

        if (hintsMap.isEmpty) {
          hintsMap = {'잎': '정보 없음', '수피': '정보 없음', '꽃': '정보 없음', '열매/겨울눈': '정보 없음', '대표': '알 수 없음'};
        }

        // 오답 보기 생성
        List<String> options = [correctName];
        final distractorData = tree['quiz_distractors'];
        List<String> manualDistractors = [];
        if (distractorData is List) {
          manualDistractors = distractorData.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
        }

        if (manualDistractors.length >= 2) {
          manualDistractors.shuffle(random);
          options.add(manualDistractors[0]);
          options.add(manualDistractors[1]);
        } else if (trees.length >= 3) {
          List<Map<String, dynamic>> otherTrees = List.from(trees)..removeAt(i);
          otherTrees.shuffle(random);
          options.add(otherTrees[0]['name_kr'] as String);
          options.add(otherTrees[1]['name_kr'] as String);
        } else {
          options.add('다른나무1');
          options.add('다른나무2');
        }

        options.shuffle(random);
        final int correctIndex = options.indexOf(correctName);

        loadedQuestions.add(
          QuizQuestion(
            id: tree['id'] is int ? tree['id'] : int.tryParse(tree['id'].toString()) ?? 0,
            imageUrl: TreeService.getProxyImageUrl(questionImageUrl),
            description: tree['description'] ?? '설명이 없습니다.',
            correctAnswerIndex: correctIndex,
            options: options,
            hints: hintsMap,
          ),
        );
      }

      return loadedQuestions;
    } catch (e) {
      debugPrint('QuizRepository.fetchQuestions Error: $e');
      rethrow;
    }
  }

  static QuizQuestion getDummyQuestion() {
    return QuizQuestion(
      id: 0,
      imageUrl: '',
      description: '로딩 중...',
      correctAnswerIndex: 0,
      options: ['Loading...'],
      hints: {},
    );
  }
}
