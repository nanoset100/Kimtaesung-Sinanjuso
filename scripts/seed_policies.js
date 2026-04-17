#!/usr/bin/env node
// ══════════════════════════════════════════════════════════
// Firestore 정책 데이터 시드 스크립트
// 김태성 신안군수 예비후보 — 6대 핵심 정책
//
// 사용 방법:
//   1. Firebase Admin SDK 서비스 계정 키 다운로드
//      Firebase Console → 프로젝트 설정 → 서비스 계정
//      → "새 비공개 키 생성" → serviceAccountKey.json 저장
//
//   2. 패키지 설치:
//      cd scripts
//      npm install
//
//   3. 환경 변수 설정:
//      set GOOGLE_APPLICATION_CREDENTIALS=./serviceAccountKey.json  (Windows)
//      export GOOGLE_APPLICATION_CREDENTIALS=./serviceAccountKey.json  (Mac/Linux)
//
//   4. 스크립트 실행:
//      node seed_policies.js
//
// ⚠️  주의: serviceAccountKey.json을 git에 절대 커밋하지 마세요!
//          .gitignore에 추가되어 있는지 확인하세요.
// ══════════════════════════════════════════════════════════

const admin = require('firebase-admin');

// Firebase Admin 초기화
admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  projectId: 'kimtaesung-sinanjuso',
});

const db = admin.firestore();

// ── 6대 핵심 정책 데이터 ──────────────────────────────────
const policies = [
  {
    id: 'tourism',
    emoji: '🏝',
    title: '관광 비전',
    subtitle: '섬 전체가 하나의 작품이 됩니다',
    category: '관광',
    sortOrder: 1,
    background:
      '신안군은 1,025개의 섬으로 이루어진 대한민국 최대 도서 지역입니다. ' +
      '각 섬의 고유한 자연·문화 자원을 체계적으로 관광 콘텐츠화하여 지역 경제를 활성화하고, ' +
      '주민의 삶 자체가 살아있는 관광 자원이 되는 선순환 구조를 만들겠습니다.',
    goals:
      '섬별 특화 콘텐츠 개발로 관광객 30% 증가, 주민 관광업 참여 소득 확대, ' +
      '신안 통합 관광 패스로 방문객 체류 기간 연장.',
    roadmap: [
      { step: 1, title: '섬별 특화 콘텐츠 개발', subtitle: '자연·문화·생활 기반 차별화' },
      { step: 2, title: '생활이 관광이 되는 구조', subtitle: '주민 삶 → 관광 자원 확장' },
      { step: 3, title: '신안 전체 관광 네트워크', subtitle: '섬 접근성·통합 관광 경험 제공' },
    ],
    averageRating: 0.0,
    ratingCount: 0,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: 'economy',
    emoji: '💰',
    title: '경제 정책',
    subtitle: '군민의 지갑이 두꺼워지는 신안',
    category: '경제',
    sortOrder: 2,
    background:
      '신안 어민과 농민이 생산한 농수산물이 제 값을 받을 수 있도록 유통구조를 근본적으로 개선합니다. ' +
      '관광·에너지 사업의 수익이 군민에게 직접 돌아오는 주민 참여 수익 공유 구조를 만들겠습니다.',
    goals:
      '농수산물 직거래 비율 40% 확대, 관광·에너지 사업 주민 수익 배분제 도입, ' +
      '군민 평균 소득 연 200만 원 이상 실질 증가.',
    roadmap: [
      { step: 1, title: '농수산물 직거래 플랫폼 구축', subtitle: '중간 유통 단계 축소' },
      { step: 2, title: '관광 수익 주민 환원', subtitle: '관광 사업 이익의 30% 지역 기금화' },
      { step: 3, title: '에너지 사업 주민 참여', subtitle: '태양광·풍력 수익 공유 조합 설립' },
    ],
    averageRating: 0.0,
    ratingCount: 0,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: 'public_service',
    emoji: '🏛',
    title: '공직자 3대 공약',
    subtitle: '공정하고 존중받는 행정',
    category: '공직',
    sortOrder: 3,
    background:
      '공직자가 군민을 위해 일하는 투명하고 공정한 행정 문화를 만들겠습니다. ' +
      '신안군 공무원들이 자부심을 갖고 일할 수 있도록 근무 환경과 복지를 개선합니다.',
    goals:
      '공직자 청렴도 전국 상위 10% 달성, 민원 처리 속도 30% 단축, ' +
      '공무원 교육 시간 연간 40시간 확대.',
    roadmap: [
      { step: 1, title: '공직자 청렴 시스템 강화', subtitle: '투명한 인사·예산 운영' },
      { step: 2, title: '민원 즉결 처리제 도입', subtitle: '24시간 내 민원 회신 원칙' },
      { step: 3, title: '공무원 역량 교육 확대', subtitle: '연간 40시간 전문성 향상 교육' },
    ],
    averageRating: 0.0,
    ratingCount: 0,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: 'open_government',
    emoji: '🤝',
    title: '열린 군정',
    subtitle: '군민과 함께 만드는 신안',
    category: '열린군정',
    sortOrder: 4,
    background:
      '군민 누구나 정책 결정 과정에 참여할 수 있는 열린 군정을 실현합니다. ' +
      '읍·면별 주민 참여 예산제를 확대하여 지역 주민이 직접 예산을 결정하게 합니다.',
    goals:
      '주민 참여 예산 비율 10% 이상 달성, 읍·면 주민 간담회 분기 1회 정례화, ' +
      '군정 주요 결정 사항 온라인 공개 100% 달성.',
    roadmap: [
      { step: 1, title: '주민 참여 예산제 확대', subtitle: '읍·면별 자율 예산 10억 원 배정' },
      { step: 2, title: '군민 정책 제안 플랫폼', subtitle: '온라인·오프라인 통합 의견 수렴' },
      { step: 3, title: '투명한 군정 공개', subtitle: '예산·사업 집행 내역 실시간 공개' },
    ],
    averageRating: 0.0,
    ratingCount: 0,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: 'civil_complaint',
    emoji: '📞',
    title: '주민불편 ZERO',
    subtitle: '불편을 말하면 바로 해결합니다',
    category: '민원',
    sortOrder: 5,
    background:
      '도서 지역 주민들의 생활 불편을 신속하게 해결하는 원스톱 민원 시스템을 구축합니다. ' +
      '섬 접근성 개선, 의료·교통 취약지 해소를 최우선 과제로 추진합니다.',
    goals:
      '민원 처리 기간 평균 5일 → 2일 단축, 도서 의료 접근성 90% 이상 보장, ' +
      '섬 여객선 운항 정시율 95% 이상 달성.',
    roadmap: [
      { step: 1, title: '원스톱 민원 처리 시스템', subtitle: '전화·앱·방문 통합 처리' },
      { step: 2, title: '도서 의료 순회 진료선', subtitle: '전남도 공모사업 연계 운영' },
      { step: 3, title: '섬 접근성 개선', subtitle: '여객선 증편·정시 운항 보장' },
    ],
    averageRating: 0.0,
    ratingCount: 0,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: 'welfare',
    emoji: '❤️',
    title: '해피100 복지',
    subtitle: '태어나서 백 세까지 행복한 신안',
    category: '복지',
    sortOrder: 6,
    background:
      '어린이부터 어르신까지 생애 전 주기에 걸쳐 촘촘한 복지 안전망을 구축합니다. ' +
      '특히 고령화 비율이 높은 도서 지역 특성에 맞는 맞춤형 복지 서비스를 제공합니다.',
    goals:
      '65세 이상 돌봄 서비스 수혜율 80% 이상, 아동 급식 지원 100% 달성, ' +
      '장애인·취약계층 자립 지원 프로그램 20개 이상 신설.',
    roadmap: [
      { step: 1, title: '어르신 맞춤 돌봄 강화', subtitle: '도서 지역 방문 돌봄·응급 알림' },
      { step: 2, title: '아동·청소년 지원 확대', subtitle: '방과후 돌봄·급식·장학금 확대' },
      { step: 3, title: '취약계층 자립 지원', subtitle: '장애인·한부모 가정 맞춤 프로그램' },
    ],
    averageRating: 0.0,
    ratingCount: 0,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
];

// ── 초기 설문 집계 데이터 ─────────────────────────────────
const surveyAggregates = [
  {
    id: 'survey_2026_q1',
    surveyId: 'survey_2026',
    questionId: 'q1',
    q1_a: 72, q1_b: 55, q1_c: 38, q1_d: 45,
    total: 210,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: 'survey_2026_q2',
    surveyId: 'survey_2026',
    questionId: 'q2',
    q2_a: 61, q2_b: 44, q2_c: 38, q2_d: 52, q2_e: 57,
    total: 252,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: 'survey_2026_q3',
    surveyId: 'survey_2026',
    questionId: 'q3',
    q3_a: 48, q3_b: 35, q3_c: 63, q3_d: 29,
    total: 175,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
];

// ── 시드 실행 함수 ────────────────────────────────────────
async function seedPolicies() {
  console.log('📋 정책 데이터 시드 시작...');
  const batch = db.batch();

  for (const policy of policies) {
    const { id, ...data } = policy;
    const ref = db.collection('policies').doc(id);
    batch.set(ref, data, { merge: true });
    console.log(`  ✅ 정책 추가: ${policy.emoji} ${policy.title} (ID: ${id})`);
  }

  await batch.commit();
  console.log(`\n✅ 정책 ${policies.length}개 시드 완료!\n`);
}

async function seedSurveyAggregates() {
  console.log('📊 설문 집계 초기 데이터 시드 시작...');
  const batch = db.batch();

  for (const agg of surveyAggregates) {
    const { id, ...data } = agg;
    const ref = db.collection('survey_aggregates').doc(id);
    batch.set(ref, data, { merge: true });
    console.log(`  ✅ 설문 집계 추가: ${id} (총 ${data.total}표)`);
  }

  await batch.commit();
  console.log(`\n✅ 설문 집계 ${surveyAggregates.length}개 시드 완료!\n`);
}

async function main() {
  console.log('🔥 Firebase Firestore 시드 시작');
  console.log('   프로젝트: kimtaesung-sinanjuso\n');

  try {
    await seedPolicies();
    await seedSurveyAggregates();

    console.log('🎉 모든 시드 완료!');
    console.log('\n다음 단계:');
    console.log('  1. Firebase Console → Firestore에서 데이터 확인');
    console.log('  2. Flutter 앱에서 Firestore 연결 확인');
    console.log('  3. Cloud Functions 배포 (survey 집계 자동화)');
  } catch (error) {
    console.error('❌ 시드 실패:', error.message);
    console.error('\n체크리스트:');
    console.error('  - GOOGLE_APPLICATION_CREDENTIALS 환경 변수 설정 여부');
    console.error('  - serviceAccountKey.json 파일 존재 여부');
    console.error('  - Firebase 프로젝트 ID (kimtaesung-sinanjuso) 일치 여부');
    process.exit(1);
  }

  process.exit(0);
}

main();
