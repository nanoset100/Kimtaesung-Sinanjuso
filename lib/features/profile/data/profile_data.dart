import 'package:flutter/material.dart';

// ── 경력 항목 모델 ────────────────────────────────────────
class CareerItem {
  final String year;
  final String title;
  final String? subtitle;

  const CareerItem({
    required this.year,
    required this.title,
    this.subtitle,
  });

  // Hive 직렬화용
  Map<String, dynamic> toMap() => {
        'year': year,
        'title': title,
        'subtitle': subtitle,
      };

  factory CareerItem.fromMap(Map<String, dynamic> map) => CareerItem(
        year: map['year'] as String,
        title: map['title'] as String,
        subtitle: map['subtitle'] as String?,
      );
}

// ── SNS 링크 모델 ─────────────────────────────────────────
class SnsLink {
  final String label;
  final String emoji;
  final Color bgColor;
  final String url;

  const SnsLink({
    required this.label,
    required this.emoji,
    required this.bgColor,
    required this.url,
  });
}

// ── 후보 프로필 정적 데이터 ──────────────────────────────
// TODO: Firebase Remote Config 또는 Firestore에서 동적으로 로드
class CandidateProfile {
  static const String name = '김태성';
  static const String title = '신안군수 예비후보';
  static const String district = '전라남도 신안군';
  static const String badge = '신안군수 예비후보';
  static const String slogan = '신안의 모든 공간을 살아있는 관광 콘텐츠로 바꾸겠습니다';

  // 경력 타임라인
  static const List<CareerItem> career = [
    CareerItem(year: '2024', title: '신안군수 예비후보 등록'),
    CareerItem(year: '2022', title: '前 신안군 지역발전위원회 위원장'),
    CareerItem(year: '2020', title: '신안 관광진흥협의회 공동대표'),
    CareerItem(year: '2018', title: '전라남도 도서지역 발전 자문위원'),
    CareerItem(year: '2015', title: '신안 어촌계 자문위원', subtitle: '도서 지역 어업인 권익 보호'),
    CareerItem(year: '2010', title: '지역 관광 위원회 부위원장'),
  ];

  // SNS 링크 (url_launcher로 외부 앱 열기)
  static const List<SnsLink> snsLinks = [
    SnsLink(
      label: 'Facebook',
      emoji: '📘',
      bgColor: Color(0xFFE3F2FD),
      // TODO: 실제 페이스북 URL로 교체
      url: 'https://www.facebook.com',
    ),
    SnsLink(
      label: 'Instagram',
      emoji: '📸',
      bgColor: Color(0xFFFCE4EC),
      // TODO: 실제 인스타그램 URL로 교체
      url: 'https://www.instagram.com',
    ),
    SnsLink(
      label: 'YouTube',
      emoji: '▶️',
      bgColor: Color(0xFFFFEBEE),
      // TODO: 실제 유튜브 URL로 교체
      url: 'https://www.youtube.com',
    ),
    SnsLink(
      label: '카카오톡',
      emoji: '💬',
      bgColor: Color(0xFFFFF9C4),
      // TODO: 실제 카카오 채널 URL로 교체 (https://pf.kakao.com/...)
      url: 'https://www.kakaocorp.com',
    ),
  ];

  // 정책 칩 (6개)
  static const List<Map<String, String>> policyChips = [
    {'emoji': '🏝', 'label': '섬 관광'},
    {'emoji': '💰', 'label': '소득 증대'},
    {'emoji': '🏛', 'label': '공정 행정'},
    {'emoji': '🤝', 'label': '열린 군정'},
    {'emoji': '📞', 'label': '민원 ZERO'},
    {'emoji': '❤️', 'label': '복지 해피100'},
  ];
}
