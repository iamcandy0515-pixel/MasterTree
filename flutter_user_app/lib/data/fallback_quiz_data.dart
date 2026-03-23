import '../models/quiz_model.dart';

List<QuizQuestion> getFallbackQuizQuestions() {
  return [
    QuizQuestion(
      id: 1,
      description: '소나무는 한국을 대표하는 상록수로, 잎이 2개씩 뭉쳐나며 붉은빛이 도는 수피가 특징입니다.',
      imageUrl: 'https://images.unsplash.com/photo-1542273917363-3b1817f69a2d?auto=format&fit=crop&q=80&w=800',
      options: ['소나무', '잣나무', '전나무'],
      correctAnswerIndex: 0,
      hints: {'잎': '2개씩 뭉쳐남', '수피': '붉은색 거북등', '대표': '애국가 소나무'},
    ),
    QuizQuestion(
      id: 2,
      description: '잣나무는 잎이 5개씩 뭉쳐나는 것이 특징입니다.',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/Pinus_koraiensis_cone.jpg/800px-Pinus_koraiensis_cone.jpg',
      options: ['소나무', '잣나무', '편백나무'],
      correctAnswerIndex: 1,
      hints: {'잎': '5개씩 뭉쳐남', '수피': '흑갈색', '대표': '잣 열매'},
    ),
    QuizQuestion(
      id: 3,
      description: '가을에 노랗게 물드는 대표적인 가로수입니다.',
      imageUrl: 'https://images.unsplash.com/photo-1507646549219-46766432098b?auto=format&fit=crop&q=80&w=800',
      options: ['단풍나무', '은행나무', '느티나무'],
      correctAnswerIndex: 1,
      hints: {'잎': '부채꼴 모양', '수피': '회색 세로 갈라짐', '대표': '살아있는 화석'},
    ),
    QuizQuestion(
      id: 4,
      description: '봄에 화려한 꽃을 피웁니다.',
      imageUrl: 'https://picsum.photos/seed/quiz3/400/400',
      options: ['벚나무', '매화나무', '살구나무'],
      correctAnswerIndex: 0,
      hints: {'잎': '톱니 있음', '수피': '가로 껍질눈', '꽃': '분홍색'},
    ),
    QuizQuestion(
      id: 5,
      description: '가을 단풍의 대명사입니다.',
      imageUrl: 'https://picsum.photos/seed/quiz5/400/400',
      options: ['신나무', '당단풍나무', '단풍나무'],
      correctAnswerIndex: 2,
      hints: {'잎': '손바닥 모양', '수피': '매끈함', '대표': '가을 붉은 잎'},
    ),
  ];
}
