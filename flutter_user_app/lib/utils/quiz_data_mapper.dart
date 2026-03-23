import 'dart:math';
import 'package:flutter_user_app/models/quiz_model.dart';
import 'package:flutter_user_app/core/api_service.dart';

class QuizDataMapper {
  static List<QuizQuestion> mapToQuestions(List<dynamic> data) {
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

        String? koreanKey = _getTypeKey(type);
        if (koreanKey != null && hint != null && hint.toString().trim().isNotEmpty) {
          hintsMap[koreanKey] = hint.toString();
        }
      }

      List<String> options = [correctName];
      final distractorData = tree['quiz_distractors'];
      if (distractorData is List && distractorData.isNotEmpty) {
        List<String> manual = distractorData.map((e) => e.toString()).toList();
        manual.shuffle(random);
        options.addAll(manual.take(2));
      } else {
        List<dynamic> others = List.from(data)..removeAt(i);
        others.shuffle(random);
        if (others.length >= 2) {
          options.add(others[0]['name_kr']);
          options.add(others[1]['name_kr']);
        }
      }

      while (options.length < 3) {
        options.add('다른 나무 ${options.length}');
      }

      options.shuffle(random);
      loadedQuestions.add(
        QuizQuestion(
          id: tree['id'] is int ? tree['id'] : int.tryParse(tree['id'].toString()) ?? 0,
          imageUrl: ApiService.getProxyImageUrl(questionImageUrl),
          description: tree['description'] ?? '설명이 없습니다.',
          correctAnswerIndex: options.indexOf(correctName),
          options: options,
          hints: hintsMap,
        ),
      );
    }

    loadedQuestions.shuffle();
    return loadedQuestions;
  }

  static String? _getTypeKey(String? type) {
    switch (type) {
      case 'main': return '대표';
      case 'leaf': return '잎';
      case 'bark': return '수피';
      case 'flower': return '꽃';
      case 'fruit': return '열매/겨울눈';
      default: return null;
    }
  }

  static List<QuizQuestion> getDummyData() {
    return [
      QuizQuestion(
        id: 1,
        description: '소나무는 한국을 대표하는 상록수로, 잎이 2개씩 뭉쳐나며 붉은빛이 도는 수피가 특징입니다.',
        imageUrl: 'https://images.unsplash.com/photo-1542273917363-3b1817f69a2d?auto=format&fit=crop&q=80&w=800',
        options: ['소나무', '잣나무', '전나무'],
        correctAnswerIndex: 0,
        hints: {'잎': '2개씩 뭉쳐남', '수피': '붉은색 거북등', '대표': '애국가 소나무'},
      ),
    ];
  }
}
