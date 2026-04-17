import 'package:flutter/material.dart';
import '../../domain/entities/policy_entity.dart';

// PRD 6대 핵심 정책 정적 데이터 — Firebase 연동 전 로컬 데이터
// TODO: Firebase 설정 완료 후 Firestore에서 실시간 집계 값(averageRating, ratingCount) 읽어오기
class PolicyRepository {
  static const List<PolicyEntity> policies = [
    PolicyEntity(
      id: 'tourism',
      emoji: '🏝',
      title: '관광 비전',
      subtitle: '섬 전체가 하나의 작품이 됩니다',
      cardColor: Color(0xFFEBF4FF),
      iconBgColor: Color(0xFFE3F2FD),
      background:
          '신안군은 1,025개의 섬으로 이루어진 대한민국 최대 도서 지역입니다. '
          '각 섬의 고유한 자연·문화 자원을 체계적으로 관광 콘텐츠화하여 지역 경제를 활성화하고, '
          '주민의 삶 자체가 살아있는 관광 자원이 되는 선순환 구조를 만들겠습니다.',
      goals: '섬별 특화 콘텐츠 개발로 관광객 30% 증가, 주민 관광업 참여 소득 확대, '
          '신안 통합 관광 패스로 방문객 체류 기간 연장.',
      roadmap: [
        RoadmapStep(step: 1, title: '섬별 특화 콘텐츠 개발', subtitle: '자연·문화·생활 기반 차별화'),
        RoadmapStep(step: 2, title: '생활이 관광이 되는 구조', subtitle: '주민 삶 → 관광 자원 확장'),
        RoadmapStep(step: 3, title: '신안 전체 관광 네트워크', subtitle: '섬 접근성·통합 관광 경험 제공'),
      ],
    ),
    PolicyEntity(
      id: 'economy',
      emoji: '💰',
      title: '경제 정책',
      subtitle: '군민의 지갑이 두꺼워지는 신안',
      cardColor: Color(0xFFFFFCE8),
      iconBgColor: Color(0xFFFFF9C4),
      background:
          '신안 어민과 농민이 생산한 농수산물이 제 값을 받을 수 있도록 유통구조를 근본적으로 개선합니다. '
          '관광·에너지 사업의 수익이 군민에게 직접 돌아오는 주민 참여 수익 공유 구조를 만들겠습니다.',
      goals: '농수산물 직거래 비율 40% 확대, 관광·에너지 사업 주민 수익 배분제 도입, '
          '군민 평균 소득 연 200만 원 이상 실질 증가.',
      roadmap: [
        RoadmapStep(step: 1, title: '농수산물 직거래 플랫폼 구축', subtitle: '중간 유통 단계 축소'),
        RoadmapStep(step: 2, title: '관광 수익 주민 환원', subtitle: '관광 사업 이익의 30% 지역 기금화'),
        RoadmapStep(step: 3, title: '에너지 사업 주민 참여', subtitle: '태양광·풍력 수익 공유 조합 설립'),
      ],
    ),
    PolicyEntity(
      id: 'public_service',
      emoji: '🏛',
      title: '공직자 3대 공약',
      subtitle: '공정하고 존중받는 행정',
      cardColor: Color(0xFFF0EEFF),
      iconBgColor: Color(0xFFE8EAF6),
      background:
          '공무원이 측근 개입 없이 소신 있게 일할 수 있는 환경을 만듭니다. '
          '직원 복지를 우선 강화하고, 폭언·인격 모독이 없는 조직 문화를 정착시키겠습니다.',
      goals: '공직자 업무 만족도 70% 이상, 부당 지시·인격 모독 사례 Zero, '
          '성과 중심 공정 인사로 유능한 인재 육성.',
      roadmap: [
        RoadmapStep(step: 1, title: '공무원 권한 회복', subtitle: '측근 개입 차단, 정책 중심 민원 처리'),
        RoadmapStep(step: 2, title: '공직자 존중 문화 정착', subtitle: '직원 복지 강화, 폭언 금지 제도화'),
        RoadmapStep(step: 3, title: '공정 인사 원칙 수립', subtitle: '다면평가 도입, 성과 중심 인사'),
      ],
    ),
    PolicyEntity(
      id: 'open_government',
      emoji: '🤝',
      title: '열린 군정',
      subtitle: '군민이 주인인 신안',
      cardColor: Color(0xFFEDFBF0),
      iconBgColor: Color(0xFFE8F5E9),
      background:
          '정책 계획부터 평가까지 모든 단계에 군민이 직접 참여하는 진정한 민주행정을 실현합니다. '
          '아이디어 공모와 온라인 의견 수렴으로 현장의 목소리를 정책에 반영하겠습니다.',
      goals: '군민 정책 제안 반영률 50% 이상, 분기별 공개 행정 보고회 개최, '
          '온라인 소통 창구 24시간 운영.',
      roadmap: [
        RoadmapStep(step: 1, title: '계획 단계 군민 참여', subtitle: '아이디어 공모·온라인 의견 수렴'),
        RoadmapStep(step: 2, title: '실행·평가 참여 확대', subtitle: '중간 점검 공개 보고회 운영'),
        RoadmapStep(step: 3, title: '열린 정보 공개', subtitle: '행정 정보 전면 공개, 소통 창구 상시화'),
      ],
    ),
    PolicyEntity(
      id: 'zero_complaint',
      emoji: '📞',
      title: '주민불편 ZERO',
      subtitle: '불편은 줄이고, 응답은 빠르게',
      cardColor: Color(0xFFFFF5EA),
      iconBgColor: Color(0xFFFFF3E0),
      background:
          '연중무휴 24시간 민원 응답 시스템을 구축해 어떤 불편도 신속하게 해결합니다. '
          '어르신 병원 동행, 전기·수도 수리 지원 등 생활 밀착형 서비스를 제공하겠습니다.',
      goals: '민원 접수 후 24시간 내 초기 답변 100%, 긴급 민원 2시간 내 현장 출동, '
          '통합 민원 플랫폼 구축으로 원스톱 처리.',
      roadmap: [
        RoadmapStep(step: 1, title: '24시간 통합 민원 접수', subtitle: '전화·문자·카카오·앱 원스톱'),
        RoadmapStep(step: 2, title: '생활 밀착형 지원 서비스', subtitle: '어르신 병원 예약·이동 지원'),
        RoadmapStep(step: 3, title: '즉각적인 현장 대응', subtitle: '읍·면 단위 전담 인력 배치'),
      ],
    ),
    PolicyEntity(
      id: 'welfare',
      emoji: '❤️',
      title: '해피100 복지',
      subtitle: '모든 군민이 편안한 신안',
      cardColor: Color(0xFFFFF0F5),
      iconBgColor: Color(0xFFFCE4EC),
      background:
          '주거·의료·교육·돌봄이 통합된 복지 시스템으로 모든 세대가 신안에서 행복하게 살 수 있는 환경을 만듭니다. '
          '배리어프리 생활환경 확대로 고령자와 장애인의 이동권을 보장하겠습니다.',
      goals: '돌봄 서비스 이용 노인 1,000명 추가, 농촌형 주거단지 조성 500세대, '
          '방과 후 돌봄 시설 모든 읍·면 설치.',
      roadmap: [
        RoadmapStep(step: 1, title: '주거·돌봄 통합 서비스', subtitle: '농촌형 주거단지·실버타운 운영'),
        RoadmapStep(step: 2, title: '의료·이동권 보장', subtitle: '교통약자 동행 서비스·의료 동행'),
        RoadmapStep(step: 3, title: '교육·안전 환경 구축', subtitle: '배리어프리 환경·방과 후 돌봄'),
      ],
    ),
  ];

  static PolicyEntity? findById(String id) {
    try {
      return policies.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
