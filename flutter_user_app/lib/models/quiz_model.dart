class QuizQuestion {
  final int id;
  final String imageUrl;
  final String description; // 정답 시 보여줄 설명
  final int correctAnswerIndex;
  final List<String> options;
  final Map<String, String> hints;

  QuizQuestion({
    required this.id,
    required this.imageUrl,
    required this.description,
    required this.correctAnswerIndex,
    required this.options,
    required this.hints,
  });
}

// 임시 더미 데이터 (나중에 Supabase 연동 시 교체)
final List<QuizQuestion> dummyQuestions = [
  QuizQuestion(
    id: 1,
    imageUrl: 'https://picsum.photos/seed/quiz1/400/400',
    description: '''[구분] 침엽수 / 상록 교목
[성상] 상록 교목, 수고 20~35m
[수형] 원추형에서 우산형으로 변화
[동정 포인트] 2개씩 뭉쳐나는 잎, 적갈색 수피''',
    correctAnswerIndex: 1,
    options: ['소나무', '잣나무', '곰솔'],
    hints: {
      '잎': '가장자리: 전연 | 배열: 호생 | 형태: 부채형',
      '수피': '갈라짐 형태: 얕음 | 색상: 회갈색 | 질감: 매끈함',
      '꽃': '개화시기: 4~5월 | 색상: 흰색 | 형태: 산방화서',
      '열매/겨울눈': '형태: 견과 | 크기: 중형 | 성숙기: 9~10월',
      '대표': '활엽수·낙엽수·양수·교목 | 개화 4~5월',
    },
  ),
  QuizQuestion(
    id: 2,
    imageUrl: 'https://picsum.photos/seed/quiz2/400/400',
    description: '''[구분] 활엽수 / 낙엽 교목
[성상] 낙엽 활엽 교목, 수고 20~30m
[수형] 넓은 빗자루 모양
[동정 포인트] 가지 끝이 갈라짐, 회백색 수피''',
    correctAnswerIndex: 2,
    options: ['이팝나무', '느티나무', '벚나무'],
    hints: {
      '잎': '가장자리: 톱니 | 배열: 어긋나기 | 형태: 타원형',
      '수피': '갈라짐 형태: 비늘처럼 벗겨짐 | 색상: 회백색',
      '꽃': '개화시기: 4~5월 | 색상: 연두색 | 형태: 취산화서',
      '열매/겨울눈': '형태: 핵과 | 크기: 소형 | 성숙기: 10월',
      '대표': '가로수, 정자목으로 많이 쓰임',
    },
  ),
  QuizQuestion(
    id: 3,
    imageUrl: 'https://picsum.photos/seed/quiz3/400/400',
    description: '벚나무는 봄에 화려한 꽃을 피우며, 수피에 가로로 된 껍질눈이 특징입니다.',
    correctAnswerIndex: 0,
    options: ['벚나무', '매화나무', '살구나무'],
    hints: {
      '잎': '가장자리: 톱니 | 형태: 타원형',
      '수피': '가로로 된 껍질눈 발달 | 흑갈색',
      '꽃': '4월 개화 | 연분홍색 | 산형화서',
      '열매/겨울눈': '버찌(핵과) | 6~7월 흑자색 성숙',
      '대표': '봄을 알리는 대표적인 꽃나무',
    },
  ),
  QuizQuestion(
    id: 4,
    imageUrl: 'https://picsum.photos/seed/quiz4/400/400',
    description: '은행나무는 잎이 부채꼴 모양이며, 가을에 노랗게 변하는 것이 특징입니다.',
    correctAnswerIndex: 1,
    options: ['단풍나무', '은행나무', '튤립나무'],
    hints: {
      '잎': '부채꼴 모양 | 가운데 갈라짐',
      '수피': '회색 | 세로로 깊게 갈라짐',
      '꽃': '4월 개화 | 암수딴그루',
      '열매/겨울눈': '노란색 종자(은행) | 악취',
      '대표': '살아있는 화석',
    },
  ),
  QuizQuestion(
    id: 5,
    imageUrl: 'https://picsum.photos/seed/quiz5/400/400',
    description: '단풍나무는 잎이 손바닥 모양으로 갈라지며, 가을에 붉게 물듭니다.',
    correctAnswerIndex: 2,
    options: ['신나무', '당단풍나무', '단풍나무'],
    hints: {
      '잎': '손바닥 모양 5~7갈래 | 마주보기',
      '수피': '회갈색 | 매끈함',
      '꽃': '5월 개화 | 붉은색 | 산방화서',
      '열매/겨울눈': '시과(날개 있음) | 10월 성숙',
      '대표': '가을 단풍의 대명사',
    },
  ),
];

enum QuizRank { eagleEye, forestKeeper, sprout }
