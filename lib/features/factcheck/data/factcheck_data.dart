import 'package:flutter/material.dart';

// ──────────────────────────────────────────────────────────
// 팩트체크 & 알림 데이터 모델
//
// CLAUDE.md §1-1 선거 무결성:
//   - GREEN/YELLOW/RED 등급만 사용, 특정인 공격 표현 금지
//   - 모든 팩트체크 항목에 공신력 있는 출처 명시
// ──────────────────────────────────────────────────────────

// ── 팩트체크 등급 ─────────────────────────────────────────
enum FactRating {
  green,   // 사실 확인됨
  yellow,  // 부분 사실 / 검토 중
  red,     // 사실과 다름
}

extension FactRatingExt on FactRating {
  String get label {
    switch (this) {
      case FactRating.green:  return '사실 확인됨';
      case FactRating.yellow: return '검토 중';
      case FactRating.red:    return '사실과 다름';
    }
  }

  Color get color {
    switch (this) {
      case FactRating.green:  return const Color(0xFF2E7D32);
      case FactRating.yellow: return const Color(0xFFF57F17);
      case FactRating.red:    return const Color(0xFFC62828);
    }
  }

  Color get bgColor {
    switch (this) {
      case FactRating.green:  return const Color(0xFFE8F5E9);
      case FactRating.yellow: return const Color(0xFFFFFDE7);
      case FactRating.red:    return const Color(0xFFFFEBEE);
    }
  }

  IconData get icon {
    switch (this) {
      case FactRating.green:  return Icons.check_circle;
      case FactRating.yellow: return Icons.info;
      case FactRating.red:    return Icons.cancel;
    }
  }

  String get emoji {
    switch (this) {
      case FactRating.green:  return '🟢';
      case FactRating.yellow: return '🟡';
      case FactRating.red:    return '🔴';
    }
  }
}

// ── 팩트체크 항목 ─────────────────────────────────────────
class FactCheckItem {
  final String id;
  final String category;       // 정책·공약·이력 등
  final String claim;          // 주장 내용
  final String verdict;        // 판정 요약
  final String detail;         // 상세 설명
  final String source;         // 출처 (공식 자료·언론)
  final String sourceUrl;      // 출처 링크
  final FactRating rating;
  final DateTime checkedAt;

  const FactCheckItem({
    required this.id,
    required this.category,
    required this.claim,
    required this.verdict,
    required this.detail,
    required this.source,
    required this.sourceUrl,
    required this.rating,
    required this.checkedAt,
  });
}

// ── FCM 알림 토픽 ─────────────────────────────────────────
enum NotificationTopic {
  campaign,   // 유세 일정 알림
  policy,     // 정책 발표 알림
  news,       // 뉴스 알림
  dday,       // 선거일 D-Day 알림
}

extension NotificationTopicExt on NotificationTopic {
  String get topicId {
    switch (this) {
      case NotificationTopic.campaign: return 'campaign_schedule';
      case NotificationTopic.policy:   return 'policy_announcement';
      case NotificationTopic.news:     return 'news_update';
      case NotificationTopic.dday:     return 'election_dday';
    }
  }

  String get label {
    switch (this) {
      case NotificationTopic.campaign: return '유세 일정 알림';
      case NotificationTopic.policy:   return '정책 발표 알림';
      case NotificationTopic.news:     return '뉴스 알림';
      case NotificationTopic.dday:     return '선거일 D-Day 알림';
    }
  }

  String get subtitle {
    switch (this) {
      case NotificationTopic.campaign: return '유세 행사 일정 및 장소 안내';
      case NotificationTopic.policy:   return '새로운 공약·정책 발표 소식';
      case NotificationTopic.news:     return '후보 관련 언론 보도 알림';
      case NotificationTopic.dday:     return '선거일 카운트다운 및 투표 독려';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationTopic.campaign: return Icons.campaign_outlined;
      case NotificationTopic.policy:   return Icons.description_outlined;
      case NotificationTopic.news:     return Icons.newspaper_outlined;
      case NotificationTopic.dday:     return Icons.how_to_vote_outlined;
    }
  }
}

// ── 알림 내역 아이템 ──────────────────────────────────────
class NotificationItem {
  final String id;
  final String title;
  final String body;
  final NotificationTopic topic;
  final DateTime receivedAt;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.topic,
    required this.receivedAt,
    this.isRead = false,
  });
}

// ── 목업 데이터 ───────────────────────────────────────────
class MockFactCheckData {
  MockFactCheckData._();

  // 선거일: 2026년 6월 3일 (제8회 전국동시지방선거)
  static final DateTime electionDate = DateTime(2026, 6, 3);

  static final List<FactCheckItem> items = [
    FactCheckItem(
      id: 'fc_001',
      category: '공약',
      claim: '"신안군 청년 일자리 1,000개 창출" 공약은 실현 가능한가?',
      verdict: '국비·도비 매칭 사업 포함 시 달성 가능한 수치',
      detail:
          '전라남도 청년 일자리 창출 사업(2025~2028)과 연계하면 신안군 배정분 약 400개, '
          '민간 투자 유치 시 추가 600개 이상이 가능합니다. 국회 예산정책처 추계 기준으로 '
          '유사 군 단위 사업에서 평균 850~1,200개 일자리가 창출된 사례가 확인됩니다.',
      source: '국회예산정책처 지역경제 분석 보고서 2025',
      sourceUrl: 'https://www.nabo.go.kr',
      rating: FactRating.green,
      checkedAt: DateTime(2026, 4, 10),
    ),
    FactCheckItem(
      id: 'fc_002',
      category: '이력',
      claim: '"전라남도청 기획조정실 근무 10년" 경력 주장',
      verdict: '공식 인사기록 기준 재직 기간 확인됨',
      detail:
          '전라남도 인사기록 및 공개 이력서를 확인한 결과, 기획조정실 내 여러 부서를 '
          '거쳐 총 재직 기간이 10년 이상임이 확인됩니다. 단, 타 부서 파견 기간 포함 여부에 '
          '따라 실제 기획조정실 직접 근무 기간은 약 8.5년으로 해석될 수도 있습니다.',
      source: '전라남도 공식 인사 발령 기록',
      sourceUrl: 'https://www.jeonnam.go.kr',
      rating: FactRating.yellow,
      checkedAt: DateTime(2026, 4, 8),
    ),
    FactCheckItem(
      id: 'fc_003',
      category: '정책',
      claim: '"신안군 섬 의료 취약지 해소: 도서 순회 진료선 운영"',
      verdict: '전남도 공모사업 선정 확인, 예산 확보 완료',
      detail:
          '2026년 전라남도 도서 의료 접근성 강화 공모사업에 신안군이 최종 선정되어 '
          '도비 50% + 국비 30% + 군비 20% 매칭으로 예산이 확보된 사실이 확인됩니다. '
          '진료선 1척 발주는 2026년 7월 예정입니다.',
      source: '전라남도 2026 도서의료지원 공모 결과 공고',
      sourceUrl: 'https://www.jeonnam.go.kr',
      rating: FactRating.green,
      checkedAt: DateTime(2026, 4, 5),
    ),
    FactCheckItem(
      id: 'fc_004',
      category: '공약',
      claim: '"신안군 전 읍·면에 스마트팜 클러스터 구축"',
      verdict: '일부 지역만 적용 가능 — 전 읍면 대상은 검토 필요',
      detail:
          '농림축산식품부 스마트팜 혁신밸리 사업 지침상 해당 사업은 2개소까지 신청 가능합니다. '
          '"전 읍·면" 구축을 위해서는 별도 군비 사업 또는 민간 투자 유치가 병행되어야 합니다. '
          '현재 타당성 조사 용역이 진행 중입니다.',
      source: '농림축산식품부 스마트팜 혁신밸리 사업 지침 2025',
      sourceUrl: 'https://www.mafra.go.kr',
      rating: FactRating.yellow,
      checkedAt: DateTime(2026, 4, 3),
    ),
  ];

  static final List<NotificationItem> recentNotifications = [
    NotificationItem(
      id: 'n_001',
      title: '📣 4월 18일 압해도 유세 일정 안내',
      body: '오후 2시 압해읍 광장에서 유세 행사가 열립니다.',
      topic: NotificationTopic.campaign,
      receivedAt: DateTime(2026, 4, 15, 9, 0),
      isRead: false,
    ),
    NotificationItem(
      id: 'n_002',
      title: '📋 농어업 공약 발표',
      body: '친환경 수산물 직거래 지원 확대 등 3개 공약이 추가되었습니다.',
      topic: NotificationTopic.policy,
      receivedAt: DateTime(2026, 4, 14, 14, 30),
      isRead: true,
    ),
    NotificationItem(
      id: 'n_003',
      title: '📰 무안일보 인터뷰 기사',
      body: '"섬 주민이 행복한 신안" — 김태성 후보 정책 인터뷰 게재',
      topic: NotificationTopic.news,
      receivedAt: DateTime(2026, 4, 13, 11, 0),
      isRead: true,
    ),
    NotificationItem(
      id: 'n_004',
      title: '🗳️ D-48 선거일이 48일 남았습니다',
      body: '6월 3일 꼭 투표해 주세요!',
      topic: NotificationTopic.dday,
      receivedAt: DateTime(2026, 4, 16, 8, 0),
      isRead: false,
    ),
  ];
}
