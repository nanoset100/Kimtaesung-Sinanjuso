// ── 뉴스 카테고리 ──────────────────────────────────────────
enum NewsCategory {
  all('전체'),
  policy('정책'),
  interview('인터뷰'),
  press('보도자료'),
  local('지역');

  final String label;
  const NewsCategory(this.label);
}

// ── 뉴스 아이템 모델 ──────────────────────────────────────
class NewsItem {
  final String id;
  final String title;
  final String source;        // 출처 언론사
  final String publishedAt;   // "2시간 전" 형식 문자열
  final DateTime publishedTime;
  final String? thumbnailUrl; // null이면 이모지 플레이스홀더
  final String thumbnailEmoji;
  final String url;           // 기사 원문 링크
  final NewsCategory category;
  final String? summary;      // 기사 요약 (있을 경우)

  const NewsItem({
    required this.id,
    required this.title,
    required this.source,
    required this.publishedAt,
    required this.publishedTime,
    this.thumbnailUrl,
    required this.thumbnailEmoji,
    required this.url,
    required this.category,
    this.summary,
  });

  // RSS XML 파싱 결과에서 생성 (Dio + xml 패키지 사용 시)
  // TODO: RSS <item> → NewsItem.fromRssItem() 구현
  factory NewsItem.fromMap(Map<String, dynamic> map) {
    return NewsItem(
      id: map['id'] as String,
      title: map['title'] as String,
      source: map['source'] as String,
      publishedAt: map['publishedAt'] as String,
      publishedTime: DateTime.parse(map['publishedTime'] as String),
      thumbnailUrl: map['thumbnailUrl'] as String?,
      thumbnailEmoji: (map['thumbnailEmoji'] as String?) ?? '📰',
      url: map['url'] as String,
      category: NewsCategory.values.firstWhere(
        (c) => c.name == (map['category'] as String),
        orElse: () => NewsCategory.all,
      ),
      summary: map['summary'] as String?,
    );
  }
}

// ── 실제 뉴스 데이터 ─────────────────────────────────────
class MockNewsData {
  static final List<NewsItem> items = [
    // ── 실제 언론 기사 (최신순) ──────────────────────────
    NewsItem(
      id: 'real_4',
      title: '조국혁신당, 신안군수 후보 선출 경선 실시되나…김태성·정광호 후보, 입당 선언',
      source: '프레시안',
      publishedAt: '3월 30일',
      publishedTime: DateTime(2026, 3, 30),
      thumbnailEmoji: '🗳',
      url: 'https://www.pressian.com/pages/articles/2026033013343735020',
      category: NewsCategory.press,
      summary: '조국혁신당 신안군수 후보 경선에 김태성·정광호 후보가 입당을 선언했다.',
    ),
    NewsItem(
      id: 'real_2',
      title: '김태성 신안군수 예비후보, 민주당 탈당 선언',
      source: '아시아경제',
      publishedAt: '3월 19일',
      publishedTime: DateTime(2026, 3, 19),
      thumbnailEmoji: '📢',
      url: 'https://www.asiae.co.kr/article/2026031911523780271',
      category: NewsCategory.press,
      summary: '김태성 예비후보가 전남도의회에서 민주당 탈당을 선언하며 "공정과 원칙이 무너졌다"고 비판했다.',
    ),
    NewsItem(
      id: 'real_1',
      title: '김태성, 신안군수 출마 선언 "청렴·공정의 군민 주인 시대 열겠다"',
      source: '뉴스1',
      publishedAt: '1월 22일',
      publishedTime: DateTime(2026, 1, 22),
      thumbnailEmoji: '🏛',
      url: 'https://www.news1.kr/local/gwangju-jeonnam/6047866',
      category: NewsCategory.press,
      summary: '주민소득·주민참여·지속가능을 군정의 3대 핵심 기준으로 제시하며 공식 출마를 선언했다.',
    ),
    NewsItem(
      id: 'real_3',
      title: '김태성 신안군수 예비후보, 민주당 심사 재심 요청',
      source: '무등일보',
      publishedAt: '12월 23일',
      publishedTime: DateTime(2025, 12, 23),
      thumbnailEmoji: '⚖️',
      url: 'https://m.mdilbo.com/detail/0kIA7d/751464',
      category: NewsCategory.press,
      summary: '당 윤리심판원에 재심을 청구하며 "사실과 원칙에 입각한 공정한 판단을 요청한다"고 밝혔다.',
    ),
  ];
}
