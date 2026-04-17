import 'package:flutter/material.dart';

// ── 문의 유형 ──────────────────────────────────────────────
enum InquiryType {
  policy('정책 의견', Icons.assignment_outlined),
  complaint('민원 신고', Icons.report_outlined),
  volunteer('자원봉사', Icons.volunteer_activism_outlined),
  press('취재 문의', Icons.camera_alt_outlined);

  final String label;
  final IconData icon;
  const InquiryType(this.label, this.icon);
}

// ── 연락처 버튼 모델 ───────────────────────────────────────
class ContactItem {
  final String label;
  final String value;
  final String url;         // url_launcher 스키마
  final IconData icon;
  final Color iconBgColor;

  const ContactItem({
    required this.label,
    required this.value,
    required this.url,
    required this.icon,
    required this.iconBgColor,
  });
}

// ── 캠프 정적 데이터 ───────────────────────────────────────
class CampContact {
  // TODO: 실제 연락처로 교체
  static const List<ContactItem> contacts = [
    ContactItem(
      label: '전화',
      value: '061-XXX-XXXX',
      url: 'tel:061XXXXXXXX',          // TODO: 실제 번호
      icon: Icons.phone_outlined,
      iconBgColor: Color(0xFFE3F2FD),
    ),
    ContactItem(
      label: '이메일',
      value: 'kimts@sinanjuso.com',
      url: 'mailto:kimts@sinanjuso.com', // TODO: 실제 이메일
      icon: Icons.email_outlined,
      iconBgColor: Color(0xFFE8F5E9),
    ),
    ContactItem(
      label: '카카오톡 채널',
      value: '@김태성신안군수',
      url: 'https://pf.kakao.com/_placeholder', // TODO: 실제 카카오 채널 URL
      icon: Icons.chat_bubble_outline,
      iconBgColor: Color(0xFFFFF9C4),
    ),
  ];

  // 신안군 안좌면 캠프 좌표 (TODO: 실제 캠프 주소 확정 후 교체)
  static const double campLatitude = 34.8353;
  static const double campLongitude = 126.1833;
  static const String campAddress = '전라남도 신안군 안좌면 김태성 선거캠프';
  static const String campAddressFull = '전라남도 신안군 안좌면 읍내리 — 캠프 사무소';
}

// ── UGC 금칙어 필터 ────────────────────────────────────────
// 앱스토어 정책 준수 (CLAUDE.md Guideline 1.2):
//   사용자 입력에 욕설·혐오 표현 필터링 적용 필수
// ──────────────────────────────────────────────────────────
class UgcFilter {
  // TODO: 서버 측 필터링 API 연동 권장 (클라이언트 단독 필터는 우회 가능)
  // 현재는 기본 금칙어 목록으로 클라이언트 1차 필터링
  static const List<String> _prohibitedWords = [
    // 욕설·비속어 (실제 배포 시 전문 필터링 서비스 연동 권장)
    '욕설1', '욕설2', '욕설3',
    // 특정인 비방 (앱스토어 정책: 상대 후보 실명 공격 금지)
    // TODO: 실제 금칙어 목록 추가 (법률 자문 후 결정)
  ];

  /// true = 금지된 표현 포함
  static bool containsProhibited(String text) {
    final lower = text.toLowerCase();
    return _prohibitedWords.any((w) => lower.contains(w.toLowerCase()));
  }

  /// 500자 제한 검사
  static bool exceedsLimit(String text, {int limit = 500}) {
    return text.length > limit;
  }

  /// 종합 검증 — (오류 메시지 null = 통과)
  static String? validate(String text) {
    if (text.trim().isEmpty) return '내용을 입력해주세요';
    if (exceedsLimit(text)) return '500자 이내로 입력해주세요';
    if (containsProhibited(text)) return '부적절한 표현이 포함되어 있습니다';
    return null;
  }
}
