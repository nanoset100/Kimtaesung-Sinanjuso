# 김태성 신안군수 예비후보 공식 선거앱 — Claude Code 작업 지침서

## 프로젝트 개요

**앱명:** 김태성과 신안  
**플랫폼:** Flutter (iOS · Android 동시 배포)  
**목적:** 신안군수 예비후보 김태성의 정책 홍보 및 유권자 소통 앱  
**언어:** 한국어 전용 (첫 번째 버전)  
**패키지명:** `com.kimtaesung.sinanjuso`

---

## ⚠️ 최우선 주의사항 — 앱스토어 정책 준수

이 앱은 **정치인 선거 앱**입니다. Google Play Console과 Apple App Store의 정치 관련 정책을 반드시 준수해야 합니다. 아래 지침을 코드와 콘텐츠 전반에 걸쳐 적용하세요.

---

## 1. Google Play Console 정책 준수 사항

### 1-1. 선거 무결성 정책 (Elections Policy)
- **허위 정보 금지:** 선거 프로세스, 투표 방법, 후보 자격에 관한 허위 또는 오해의 소지가 있는 정보를 포함하지 말 것
- **팩트체크 기능:** 모든 정책 발언에 공신력 있는 출처(공식 보도자료, 언론 링크)를 명시할 것
- **투표 독려:** 투표 방해(voter suppression) 콘텐츠 절대 금지. 알림은 "투표하세요"처럼 중립적으로만 작성

### 1-2. 개인정보 및 데이터 정책
- **최소 데이터 수집 원칙:** 설문·투표 참여 시 이름·연락처 등 식별 가능 정보 수집 금지
- **Privacy Policy URL:** 앱 스토어 등록 시 개인정보처리방침 페이지 필수 등록
- **Data Safety 섹션:** Google Play Console의 Data Safety 폼을 정확히 작성할 것
  - 위치 데이터: 투표소 안내 시에만 사용, 서버 전송 금지
  - 분석 데이터: Firebase Analytics 사용 시 "데이터 수집됨" 명시

### 1-3. 광고 정책
- **정치 광고 금지:** 앱 내에 Google AdMob 등 광고 SDK 삽입 금지 (정치 앱 광고 정책 위반)
- **후원금 수집:** 앱 내에서 직접 후원금/기부금 결제 버튼을 만들지 말 것. 외부 링크로만 안내

### 1-4. 민감한 콘텐츠
- 상대 후보나 현직 군수를 직접 비방·공격하는 콘텐츠 금지
- 팩트체크 등급은 GREEN/YELLOW/RED로만 표시하고, 특정인 공격으로 오해될 표현 사용 금지

---

## 2. Apple App Store 정책 준수 사항

### 2-1. App Review Guidelines 준수 항목
- **Guideline 1.2 (User Generated Content):** 설문·의견 제출 기능에는 욕설·혐오 표현 필터링 적용 필수
- **Guideline 2.3 (Accurate Metadata):** 앱 설명에 "특정 정당 지지" 등의 표현 사용 시 명확히 표기
- **Guideline 5.1 (Privacy):** 위치 정보 접근 시 "투표소 안내 목적"임을 info.plist에 명확히 기재

### 2-2. 결제 정책 (Guideline 3.1)
- 앱 내에서 후원금을 직접 받는 결제 흐름을 구현하면 Apple In-App Purchase 적용 대상이 됨
- **해결책:** 후원 안내는 외부 Safari 링크 열기로만 처리 (`url_launcher` 패키지 사용)

### 2-3. 연령 등급
- **권장 등급:** 4+ (만 4세 이상) — 폭력·성인 콘텐츠 없음
- 설문/투표 기능에 유해 콘텐츠가 입력될 수 있으므로 서버 측 필터링 구현 필요

### 2-4. 리뷰 통과 팁
- 앱 설명(App Store Connect)에 "선거 캠프 공식 앱"임을 명시
- 심사 메모에 "지방선거 후보 공식 앱, 대한민국 선거법 준수"를 영문으로 기재
- 심사용 테스트 계정 및 데모 영상 준비

---

## 3. 대한민국 공직선거법 준수

- **선거운동 기간:** 공직선거법상 선거운동 기간(선거일 전 14일~선거일 전일) 외에는 앱 기능 일부 제한 필요
- **후보 기호·사진:** 선관위 승인 후보 등록 완료 전까지 "예비후보" 표기 유지
- **비용 신고:** 앱 개발비는 선거비용 신고 대상일 수 있음 — 캠프 법률팀 확인 필요

---

## 4. Flutter 기술 스택

```yaml
# pubspec.yaml 핵심 의존성
dependencies:
  flutter: sdk
  
  # 상태 관리
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.4
  
  # 네트워크
  dio: ^5.4.3
  retrofit: ^4.1.0
  
  # 로컬 DB (오프라인 캐시)
  hive_flutter: ^1.1.0
  
  # Firebase
  firebase_core: ^2.30.1
  firebase_analytics: ^10.10.1
  firebase_messaging: ^14.9.1  # Push 알림
  cloud_firestore: ^4.17.2     # 설문 결과 저장
  
  # UI
  cached_network_image: ^3.3.1
  flutter_svg: ^2.0.10
  shimmer: ^3.0.0              # 로딩 스켈레톤
  
  # 지도
  google_maps_flutter: ^2.6.0
  
  # 링크/연락
  url_launcher: ^6.3.0
  
  # 알림 스케줄
  flutter_local_notifications: ^17.2.1
  
  # 분석
  share_plus: ^9.0.0
  
  # 접근성
  flutter_tts: ^3.8.5          # 고령자 텍스트 음성 변환

dev_dependencies:
  build_runner: ^2.4.9
  riverpod_generator: ^2.3.9
  retrofit_generator: ^8.1.0
```

---

## 5. 프로젝트 디렉토리 구조

```
lib/
├── main.dart
├── app.dart                          # MaterialApp, Router 설정
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart           # 색상 상수 (Blue #1B3A6B, Accent #E8941A)
│   │   ├── app_strings.dart          # 한국어 문자열 상수
│   │   └── app_typography.dart       # 폰트 크기 (최소 16sp)
│   ├── router/
│   │   └── app_router.dart           # GoRouter 라우팅
│   ├── theme/
│   │   └── app_theme.dart            # Material 3 테마
│   └── utils/
│       ├── date_formatter.dart
│       └── url_helper.dart           # 외부 링크 처리
│
├── features/
│   ├── profile/                      # Feature 1: 정치인 프로필
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── profile_screen.dart
│   │       └── widgets/
│   │           ├── career_timeline_widget.dart
│   │           └── social_links_widget.dart
│   │
│   ├── policy/                       # Feature 2: 정책 소개 (★핵심)
│   │   ├── data/
│   │   │   ├── models/policy_model.dart
│   │   │   └── repositories/policy_repository.dart
│   │   ├── domain/
│   │   │   └── entities/policy_entity.dart
│   │   └── presentation/
│   │       ├── policy_list_screen.dart   # 6개 정책 카드 목록
│   │       ├── policy_detail_screen.dart # 정책 상세 (배경·목표·로드맵)
│   │       └── widgets/
│   │           ├── policy_card_widget.dart
│   │           ├── policy_roadmap_widget.dart
│   │           └── policy_rating_widget.dart   # 별점 평가
│   │
│   ├── news/                         # Feature 3: 뉴스 피드
│   │   └── presentation/
│   │       ├── news_feed_screen.dart
│   │       └── widgets/
│   │           └── news_card_widget.dart
│   │
│   ├── contact/                      # Feature 4: 직접 연락
│   │   └── presentation/
│   │       ├── contact_screen.dart
│   │       └── widgets/
│   │           ├── contact_button_widget.dart
│   │           └── camp_map_widget.dart
│   │
│   ├── survey/                       # Feature 5: 설문 및 투표
│   │   └── presentation/
│   │       ├── survey_screen.dart
│   │       ├── survey_result_screen.dart
│   │       └── widgets/
│   │           └── vote_chart_widget.dart
│   │
│   └── factcheck/                    # Feature 6: 팩트체크 & 알림
│       └── presentation/
│           ├── factcheck_screen.dart
│           ├── notification_settings_screen.dart
│           └── widgets/
│               ├── factcheck_badge_widget.dart
│               └── countdown_widget.dart       # D-Day 카운트다운
│
├── shared/
│   ├── widgets/
│   │   ├── bottom_nav_bar.dart       # 하단 네비게이션 (5개 탭)
│   │   ├── loading_skeleton.dart
│   │   └── error_view.dart
│   └── providers/
│       └── connectivity_provider.dart # 오프라인 감지
│
└── l10n/
    └── app_ko.arb                    # 한국어 문자열 (국제화 준비)
```

---

## 6. 핵심 화면별 구현 우선순위

| 우선순위 | 화면 | 이유 |
|---------|------|------|
| P0 | 정책 소개 리스트·상세 | 앱의 핵심 가치 |
| P0 | 정치인 프로필 | 랜딩 페이지 역할 |
| P1 | 뉴스 피드 | 재방문 유도 |
| P1 | 직접 연락 | 유권자 소통 |
| P2 | 설문 및 투표 | 참여형 기능 |
| P2 | 팩트체크 & 알림 | 신뢰도·알림 |

---

## 7. 앱스토어 금지 패턴 — 코드 레벨 체크리스트

### 절대 구현하지 말 것
```dart
// ❌ 앱 내 정치 기부금 결제 (Google Play/App Store 정책 위반)
// EasyPayment.charge(amount: 10000, purpose: "후원금");

// ❌ 상대 후보 실명 비방 콘텐츠
// Text("현직 박우량 군수는 비리 정치인입니다");

// ❌ 개인 식별 가능 설문 데이터 서버 전송
// FirebaseFirestore.instance.collection('votes').add({'name': userName, 'vote': choice});

// ❌ 위치 데이터 서버 저장
// analytics.logEvent(name: 'user_location', parameters: {'lat': lat, 'lng': lng});
```

### 반드시 구현할 것
```dart
// ✅ 외부 링크로만 후원 안내
Future<void> openDonationPage() async {
  final uri = Uri.parse('https://campaign.kimtaesung.com/support');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

// ✅ 익명 설문 (해시 처리)
Future<void> submitVote(String policyId, int rating) async {
  final anonymousId = sha256.convert(utf8.encode(deviceId + policyId)).toString();
  await FirebaseFirestore.instance.collection('survey_results').doc(anonymousId).set({
    'policyId': policyId,
    'rating': rating,
    'timestamp': FieldValue.serverTimestamp(),
    // 절대 개인정보 포함 금지
  });
}

// ✅ UGC 필터링 (사용자 의견 입력 시)
bool containsProhibitedContent(String text) {
  const prohibited = ['욕설1', '욕설2']; // 금칙어 목록
  return prohibited.any((word) => text.contains(word));
}

// ✅ 접근성 — 최소 터치 영역
ElevatedButton(
  style: ElevatedButton.styleFrom(
    minimumSize: const Size(48, 48), // WCAG 2.1 AA 기준
  ),
  onPressed: () {},
  child: const Text('확인', style: TextStyle(fontSize: 16)),
)
```

---

## 8. Firebase 프로젝트 설정 요구사항

- **프로젝트명:** `kimtaesung-sinanjuso`
- **Analytics:** 익명 집계만 허용 (개인 식별 이벤트 로깅 금지)
- **Firestore Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 정책 데이터: 읽기만 허용
    match /policies/{id} {
      allow read: if true;
      allow write: if false; // 앱에서 수정 불가
    }
    // 설문 결과: 익명 쓰기만 허용
    match /survey_results/{id} {
      allow read: if false;   // 앱에서 개별 결과 열람 금지
      allow create: if request.resource.data.keys().hasOnly(['policyId', 'rating', 'timestamp']);
    }
    // 집계 데이터: 읽기만 허용
    match /survey_aggregates/{id} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

---

## 9. 개인정보처리방침 필수 포함 항목

앱 출시 전 아래 항목을 포함한 개인정보처리방침 페이지를 웹에 게시하고 URL을 스토어에 등록:

1. 수집하는 정보: 기기 식별자(익명), 앱 사용 로그만 수집
2. 수집하지 않는 정보: 이름, 연락처, 위치(투표소 기능 제외), 정치적 성향
3. 데이터 보관 기간: 선거 종료 후 30일 이내 전량 삭제
4. 제3자 제공: Firebase(Google) 분석 도구 사용 명시
5. 문의처: 캠프 이메일 주소

---

## 10. 빌드 및 배포 체크리스트

### Google Play 제출 전
- [ ] Data Safety 폼 완성 (정치 관련 데이터 처리 명시)
- [ ] 앱 설명에 "지방선거 후보 공식 앱" 명시
- [ ] 타겟 SDK 34 이상 설정
- [ ] 앱 서명 키 생성 및 보관
- [ ] 개인정보처리방침 URL 등록

### App Store 제출 전
- [ ] info.plist 권한 설명 (위치: 투표소 안내 목적)
- [ ] App Privacy 섹션 작성
- [ ] 심사 메모 영문 작성: "Official campaign app for local government candidate in South Korea. Complies with Korean Election Law."
- [ ] 연령 등급: 4+
- [ ] 테스트 계정 및 데모 영상 준비

---

*이 문서는 Claude Code가 개발 작업 시 항상 참조해야 하는 최우선 지침입니다.*
*정책 관련 법률 판단은 반드시 캠프 법률 자문인에게 확인하세요.*
