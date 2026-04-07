import 'dart:math';
import 'package:flutter_user_app/models/quiz_model.dart';
import 'package:flutter_user_app/core/api_service.dart';

class QuizDataMapper {
  static List<QuizQuestion> mapToQuestions(List<dynamic> data) {
    List<QuizQuestion> loadedQuestions = [];
    final random = Random();

    for (int i = 0; i < data.length; i++) {
      final Map<String, dynamic> tree = Map<String, dynamic>.from(data[i] as Map);
      final String correctName = (tree['name_kr'] as String?) ?? '이름 없음';
      Map<String, String> hintsMap = {};
      String questionImageUrl = '';

      final List<dynamic> images = (tree['tree_images'] as List<dynamic>?) ?? <dynamic>[];
      for (final dynamic imgRaw in images) {
        final Map<String, dynamic> img = Map<String, dynamic>.from(imgRaw as Map);
        final String? type = img['image_type'] as String?;
        final dynamic hint = img['hint'];
        final String? url = img['image_url'] as String?;

        if (url != null && url.isNotEmpty) {
          if (type == 'main' || questionImageUrl.isEmpty) {
            questionImageUrl = url;
          }
        }

        final String? koreanKey = _getTypeKey(type);
        if (koreanKey != null && hint != null && hint.toString().trim().isNotEmpty) {
          hintsMap[koreanKey] = hint.toString();
        }
      }

      List<String> options = [correctName];
      final dynamic distractorData = tree['quiz_distractors'];
      if (distractorData is List && distractorData.isNotEmpty) {
        final List<String> manual = distractorData.map((dynamic e) => e.toString()).toList();
        manual.shuffle(random);
        options.addAll(manual.take(2));
      } else {
        final List<dynamic> others = List<dynamic>.from(data)..removeAt(i);
        others.shuffle(random);
        if (others.length >= 2) {
          options.add((Map<String, dynamic>.from(others[0] as Map))['name_kr'] as String);
          options.add((Map<String, dynamic>.from(others[1] as Map))['name_kr'] as String);
        }
      }

      while (options.length < 3) {
        options.add('다른 나무 ${options.length}');
      }

      options.shuffle(random);
      loadedQuestions.add(
        QuizQuestion(
          id: tree['id'] is int ? tree['id'] as int : int.tryParse(tree['id'].toString()) ?? 0,
          imageUrl: ApiService.getProxyImageUrl(questionImageUrl),
          description: (tree['description'] as String?) ?? '설명이 없습니다.',
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
    final lowerType = type?.toLowerCase().trim() ?? '';
    if (lowerType == 'main' || lowerType == '전체' || lowerType == '대표' || lowerType == 'full') return '전체';
    if (lowerType == 'leaf' || lowerType == '잎' || lowerType == '잎새' || lowerType == 'leaves') return '잎';
    if (lowerType == 'bark' || lowerType == '수피' || lowerType == '나무껍질' || lowerType == 'bark_skin') return '수피';
    if (lowerType == 'flower' || lowerType == '꽃' || lowerType == 'blossom') return '꽃';
    if (lowerType == 'fruit' || lowerType == '열매' || lowerType == 'fruit_bud' || lowerType == 'winter_bud') return '열매/겨울눈';
    return null;
  }

  static List<QuizQuestion> getDummyData() {
    return <QuizQuestion>[
      QuizQuestion(
        id: 1,
        description: '소나무는 한국을 대표하는 상록수로, 잎이 2개씩 뭉쳐나며 붉은빛이 도는 수피가 특징입니다.',
        imageUrl: 'https://images.unsplash.com/photo-1542273917363-3b1817f69a2d?auto=format&fit=crop&q=80&w=800',
        options: <String>['소나무', '잣나무', '전나무'],
        correctAnswerIndex: 0,
        hints: <String, String>{'잎': '2개씩 뭉쳐남', '수피': '붉은색 거북등', '전체': '애국가 소나무'},
      ),
    ];
  }
}
