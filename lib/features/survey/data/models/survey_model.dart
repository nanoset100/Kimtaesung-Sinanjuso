// ── 설문 선택지 ────────────────────────────────────────────
class SurveyOption {
  final String id;
  final String text;

  const SurveyOption({required this.id, required this.text});

  Map<String, dynamic> toMap() => {'id': id, 'text': text};

  factory SurveyOption.fromMap(Map<String, dynamic> m) =>
      SurveyOption(id: m['id'] as String, text: m['text'] as String);
}

// ── 설문 문항 ──────────────────────────────────────────────
class SurveyQuestion {
  final String id;
  final String surveyId;   // 소속 설문 ID
  final String question;
  final List<SurveyOption> options;

  const SurveyQuestion({
    required this.id,
    required this.surveyId,
    required this.question,
    required this.options,
  });
}

// ── 집계 결과 (Firestore survey_aggregates 에서 읽음) ───────
class SurveyAggregate {
  final String surveyId;
  final String questionId;
  final Map<String, int> counts;   // optionId → 투표 수
  final int total;

  const SurveyAggregate({
    required this.surveyId,
    required this.questionId,
    required this.counts,
    required this.total,
  });

  double percentOf(String optionId) {
    if (total == 0) return 0;
    return (counts[optionId] ?? 0) / total;
  }

  factory SurveyAggregate.empty(String surveyId, String questionId) =>
      SurveyAggregate(
        surveyId: surveyId,
        questionId: questionId,
        counts: {},
        total: 0,
      );

  factory SurveyAggregate.fromMap(
      String surveyId, String questionId, Map<String, dynamic> m) {
    final counts = <String, int>{};
    int total = 0;
    m.forEach((k, v) {
      if (k != 'total') {
        counts[k] = (v as num).toInt();
        total += counts[k]!;
      }
    });
    return SurveyAggregate(
      surveyId: surveyId,
      questionId: questionId,
      counts: counts,
      total: total,
    );
  }
}

// ── 목업 설문 데이터 ───────────────────────────────────────
// TODO: Firestore surveys/ 컬렉션에서 동적으로 로드
class MockSurveyData {
  static const List<SurveyQuestion> questions = [
    SurveyQuestion(
      id: 'q1',
      surveyId: 'survey_2026',
      question: '신안군에서 가장 시급히 해결해야 할 문제는 무엇이라고 생각하십니까?',
      options: [
        SurveyOption(id: 'q1_a', text: '주민 생활 편의 (의료·교통)'),
        SurveyOption(id: 'q1_b', text: '지역 경제 활성화'),
        SurveyOption(id: 'q1_c', text: '관광 인프라 개선'),
        SurveyOption(id: 'q1_d', text: '복지·돌봄 서비스'),
      ],
    ),
    SurveyQuestion(
      id: 'q2',
      surveyId: 'survey_2026',
      question: '김태성 후보의 6대 공약 중 가장 중요하다고 생각하는 정책은?',
      options: [
        SurveyOption(id: 'q2_a', text: '🏝 관광 비전'),
        SurveyOption(id: 'q2_b', text: '💰 경제 정책 (소득 증대)'),
        SurveyOption(id: 'q2_c', text: '🤝 열린 군정'),
        SurveyOption(id: 'q2_d', text: '❤️ 해피100 복지'),
        SurveyOption(id: 'q2_e', text: '📞 주민불편 ZERO'),
      ],
    ),
    SurveyQuestion(
      id: 'q3',
      surveyId: 'survey_2026',
      question: '신안군 발전을 위해 군수가 가장 집중해야 할 분야는?',
      options: [
        SurveyOption(id: 'q3_a', text: '일자리 창출'),
        SurveyOption(id: 'q3_b', text: '인구 유입 정책'),
        SurveyOption(id: 'q3_c', text: '섬 접근성 개선'),
        SurveyOption(id: 'q3_d', text: '교육 환경 강화'),
      ],
    ),
  ];

  // 로컬 목업 집계 데이터 (Firebase 연동 전)
  static SurveyAggregate mockAggregate(String questionId) {
    final mockData = <String, Map<String, int>>{
      'q1': {'q1_a': 72, 'q1_b': 55, 'q1_c': 38, 'q1_d': 45},
      'q2': {'q2_a': 61, 'q2_b': 44, 'q2_c': 38, 'q2_d': 52, 'q2_e': 57},
      'q3': {'q3_a': 83, 'q3_b': 66, 'q3_c': 59, 'q3_d': 41},
    };
    final counts = mockData[questionId] ?? {};
    final total = counts.values.fold(0, (a, b) => a + b);
    return SurveyAggregate(
      surveyId: 'survey_2026',
      questionId: questionId,
      counts: counts,
      total: total,
    );
  }
}
