# 🚀 김태성과 신안 — 웹사이트 개발 계획 (수정본)

**프로젝트**: 신안군수 예비후보 캠프 공식 웹사이트  
**개발 기간**: 47일 (선거일까지)  
**실제 개발**: 28-32일 + 마케팅 준비 15일  
**개발자**: 1인 (풀스택)  
**도메인**: kimtaesung.kr (✅ 등록됨)

---

## 📋 핵심 개선사항

| 항목 | 기존 계획 | 수정 계획 | 효과 |
|------|---------|---------|------|
| **UI 라이브러리** | Tailwind만 | **Shadcn/ui** | 개발 시간 50% 단축 |
| **호스팅** | Railway | **Vercel** | 배포 설정 시간 90% 단축 |
| **문의 폼** | SendGrid API | **Formspree (fetch 비동기)** | 백엔드 코드 완전 제거 + UX 유지 |
| **분석** | 없음 | **GA4** | 실시간 데이터 기반 마케팅 |
| **앱 연동** | 다운로드 버튼 | **Smart App Banner (SSR metadata)** | 웹→앱 전환율 3배 향상 |

> ⚠️ **v2 수정사항** (제미나이 피드백 반영):
> 1. Smart App Banner → `useEffect` 제거, `metadata` 객체로 이동 (SSR 보장)
> 2. Formspree → `action=""` 방식 대신 `fetch` 비동기로 변경 (페이지 이동 없음)
> 3. Shadcn/ui 명령어 → `npx shadcn-ui@latest` → `npx shadcn@latest`

---

## 📅 전체 타임라인

```
Week 1 (Day 1-7)
├─ STEP 1-3: 환경 셋업 (Vercel + Shadcn/ui + Contentful)
└─ 예상 시간: 8시간

Week 2-3 (Day 8-21)
├─ STEP 4-7: 페이지 개발 (홈 + 정책 + 뉴스 + 연락)
└─ 예상 시간: 20시간

Week 4 (Day 22-28)
├─ STEP 8-10: 배포 + 최적화 + GA4
└─ 예상 시간: 6시간

Week 5-6 (Day 29-47)
├─ 콘텐츠 작성 + 최종 테스트 + 마케팅
└─ 예상 시간: 버퍼 + 마케팅 준비
```

---

# 🛠️ 상세 Step-by-Step 계획

## **STEP 1: 프로젝트 셋업** (Day 1 | 3시간)

### 1-1. Node.js 버전 확인
```bash
node --version   # v18+ 필요
npm --version
git --version
```

### 1-2. Next.js 프로젝트 생성 (Shadcn/ui 포함)
```bash
# Next.js 프로젝트 생성
npx create-next-app@latest sinanjuso-web \
  --typescript \
  --tailwind \
  --eslint \
  --src-dir \
  --app \
  --import-alias "@/*"

cd sinanjuso-web

# Shadcn/ui 초기화 (UI 라이브러리) — 최신 명령어 사용
# ⚠️ 구버전: npx shadcn-ui@latest init (작동 안 할 수 있음)
npx shadcn@latest init

# Contentful 패키지 설치
npm install contentful axios next-sitemap sharp
```

### 1-3. 프로젝트 폴더 구조
```
sinanjuso-web/
├─ src/
│  ├─ app/
│  │  ├─ layout.tsx
│  │  ├─ page.tsx           # 홈페이지
│  │  ├─ policies/
│  │  │  └─ page.tsx        # 정책 페이지
│  │  ├─ news/
│  │  │  └─ page.tsx        # 뉴스 페이지
│  │  ├─ contact/
│  │  │  └─ page.tsx        # 연락 페이지
│  │  └─ globals.css
│  ├─ components/
│  │  ├─ Header.tsx
│  │  ├─ Footer.tsx
│  │  ├─ Hero.tsx
│  │  ├─ PolicyGrid.tsx
│  │  ├─ PolicyCard.tsx
│  │  ├─ CountdownTimer.tsx
│  │  ├─ AppDownloadBanner.tsx
│  │  ├─ SmartAppBanner.tsx
│  │  └─ NewsCard.tsx
│  └─ lib/
│     ├─ contentful.ts      # Contentful 클라이언트
│     └─ types.ts           # TypeScript 타입
├─ public/
│  ├─ images/
│  ├─ og-image.png         # OG 썸네일 (1200x630)
│  └─ favicon.ico
├─ .env.local              # 환경 변수
├─ next.config.js
└─ tailwind.config.ts
```

### 1-4. Vercel 배포 준비
```bash
# GitHub 저장소 생성
git init
git add .
git commit -m "Initial commit: Next.js + Shadcn/ui setup"
git remote add origin https://github.com/{your-username}/sinanjuso-web
git push -u origin main

# Vercel 대시보드 (https://vercel.com)
# → Import Project → GitHub 연결 → kimtaesung.kr 도메인 설정
```

### 1-5. 환경 변수 설정
```bash
# .env.local 파일 생성
NEXT_PUBLIC_CONTENTFUL_SPACE_ID=xxx
NEXT_PUBLIC_CONTENTFUL_ACCESS_TOKEN=xxx
NEXT_PUBLIC_GA_MEASUREMENT_ID=G-XXXXXXXXXX
```

### ✅ STEP 1 완료 조건
- [ ] `npm run dev` 에러 없음
- [ ] http://localhost:3000 접속 가능 (Shadcn 기본 페이지)
- [ ] GitHub 저장소 생성됨
- [ ] Vercel 프로젝트 연결됨 (자동 배포 설정)

---

## **STEP 2: Contentful 스키마 설계** (Day 1-2 | 2시간)

### 2-1. Contentful 가입 및 Space 생성
```
https://www.contentful.com → Sign Up (무료)
Space 이름: "kimtaesung-sinanjuso"
```

### 2-2. Content Model 설계 (4가지)

#### 모델 1: Policy (정책)
```
필드:
- title (Text, 필수)
- description (Rich Text, 필수)
- icon (Media, 필수)
- roadmap (Rich Text)
- order (Number) — 1-6 정렬순
```

#### 모델 2: News (뉴스)
```
필드:
- title (Text, 필수)
- excerpt (Text, 필수) — 200자
- content (Rich Text, 필수)
- featuredImage (Media)
- publishedAt (Date, 필수)
- externalLink (Text, 옵션)
- category (Text) — "보도자료" 또는 "뉴스"
```

#### 모델 3: Settings (전역 설정)
```
필드:
- siteName (Text)
- description (Text)
- daysUntilElection (Number)
- contactEmail (Text)
- contactPhone (Text)
- address (Text)
- socialLinks (JSON) — {"instagram": "...", "youtube": "..."}
```

#### 모델 4: ContactSubmission (연락 저장)
```
필드:
- name (Text)
- email (Text)
- message (Text)
- submittedAt (Date, 자동)

💡 이 모델은 Formspree가 대신 관리하므로 참고용
```

### 2-3. API 키 발급
```
Contentful Dashboard → Settings → API Keys
"Content Delivery API" 복사:
  - Space ID
  - Access Token

.env.local에 추가:
NEXT_PUBLIC_CONTENTFUL_SPACE_ID=xxx
NEXT_PUBLIC_CONTENTFUL_ACCESS_TOKEN=xxx
```

### ✅ STEP 2 완료 조건
- [ ] Contentful Space 생성됨
- [ ] 4개 Content Model 정의됨
- [ ] API 키 발급 후 .env.local 저장됨

---

## **STEP 3: Contentful 클라이언트 구현** (Day 2 | 2시간)

### 3-1. Contentful 클라이언트 라이브러리
```typescript
// src/lib/contentful.ts
import { createClient } from 'contentful';

const client = createClient({
  space: process.env.NEXT_PUBLIC_CONTENTFUL_SPACE_ID!,
  accessToken: process.env.NEXT_PUBLIC_CONTENTFUL_ACCESS_TOKEN!,
});

// 정책 가져오기
export async function getPolicies() {
  const entries = await client.getEntries({
    content_type: 'policy',
    order: 'fields.order',
  });
  return entries.items as any[];
}

// 뉴스 가져오기
export async function getNews(limit = 10) {
  const entries = await client.getEntries({
    content_type: 'news',
    limit,
    order: '-fields.publishedAt',
  });
  return entries.items as any[];
}

// 설정 가져오기
export async function getSettings() {
  const entries = await client.getEntries({
    content_type: 'settings',
    limit: 1,
  });
  return entries.items[0]?.fields as any;
}
```

### 3-2. TypeScript 타입
```typescript
// src/lib/types.ts
export interface Policy {
  title: string;
  description: string;
  icon: { url: string };
  roadmap: string;
  order: number;
}

export interface News {
  title: string;
  excerpt: string;
  content: string;
  featuredImage?: { url: string };
  publishedAt: string;
  externalLink?: string;
  category: string;
}

export interface Settings {
  siteName: string;
  description: string;
  daysUntilElection: number;
  contactEmail: string;
  contactPhone: string;
  address: string;
  socialLinks: Record<string, string>;
}
```

### ✅ STEP 3 완료 조건
- [ ] src/lib/contentful.ts 작성됨
- [ ] src/lib/types.ts 작성됨
- [ ] `npm run dev` 에러 없음

---

## **STEP 4: 홈페이지 개발** (Day 3-5 | 6시간)

### 4-1. 레이아웃 (Layout)
```typescript
// src/app/layout.tsx
import type { Metadata } from 'next';
import Header from '@/components/Header';
import Footer from '@/components/Footer';
// ❌ SmartAppBanner import 제거 (useEffect 방식 사용하지 않음)
import './globals.css';

export const metadata: Metadata = {
  title: '김태성과 신안 - 신안군수 예비후보',
  description: '신안의 미래를 함께 만드는 공식 캠프',
  // ✅ iOS Smart App Banner — SSR에서 렌더링되므로 Safari가 즉시 인식
  itunes: {
    appId: '1234567890',          // App Store Connect에서 확인
    appArgument: 'kimtaesung://', // 딥링크 (옵션)
  },
  // ✅ Android Google Play — other 필드로 커스텀 메타 태그 추가
  other: {
    'google-play-app': 'app-id=com.kimtaesung.sinanjuso',
  },
  openGraph: {
    title: '김태성과 신안',
    description: '신안군수 예비후보 김태성 공식 웹사이트',
    url: 'https://kimtaesung.kr',
    siteName: '김태성과 신안',
    images: [{ url: '/og-image.png', width: 1200, height: 630 }],
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ko">
      <body className="bg-gray-50 text-gray-900">
        {/* ❌ SmartAppBanner 컴포넌트 제거 — metadata.itunes로 대체 */}
        <Header />
        <main className="min-h-screen">{children}</main>
        <Footer />
      </body>
    </html>
  );
}
```

### 4-2. 홈페이지
```typescript
// src/app/page.tsx
import { getPolicies, getSettings } from '@/lib/contentful';
import Hero from '@/components/Hero';
import PolicyGrid from '@/components/PolicyGrid';
import CountdownTimer from '@/components/CountdownTimer';
import AppDownloadBanner from '@/components/AppDownloadBanner';

export const revalidate = 3600; // 1시간 ISR 캐싱

export default async function Home() {
  const [policies, settings] = await Promise.all([
    getPolicies(),
    getSettings(),
  ]);

  return (
    <>
      <Hero settings={settings} />
      <CountdownTimer daysLeft={settings.daysUntilElection} />
      
      <section className="py-16 px-4 max-w-6xl mx-auto">
        <h2 className="text-4xl font-bold text-center mb-12">핵심 정책</h2>
        <PolicyGrid policies={policies} />
      </section>
      
      <AppDownloadBanner />
    </>
  );
}
```

### 4-3. 주요 컴포넌트 (Shadcn/ui 사용으로 시간 단축)

#### Smart App Banner — metadata 방식 (SSR 보장)

> ⚠️ **중요**: `useEffect`로 `<meta>` 태그를 삽입하면 iOS Safari가 초기 로딩 시 인식하지 못합니다.  
> Next.js `metadata` 객체를 사용하면 SSR 단계에서 HTML에 포함되므로 배너가 정확히 작동합니다.

```typescript
// src/app/layout.tsx — metadata에 통합
export const metadata: Metadata = {
  title: '김태성과 신안 - 신안군수 예비후보',
  description: '신안의 미래를 함께 만드는 공식 캠프',
  // ✅ iOS Smart App Banner (SSR, 서버에서 렌더링됨)
  itunes: {
    appId: '1234567890',         // App Store에서 발급받은 앱 ID
    appArgument: 'kimtaesung://', // 앱 내 딥링크 (옵션)
  },
  // ✅ Android는 커스텀 메타 태그로 처리 (아래 other 필드 활용)
  other: {
    'google-play-app': 'app-id=com.kimtaesung.sinanjuso',
  },
  openGraph: {
    title: '김태성과 신안',
    description: '신안군수 예비후보 김태성 공식 웹사이트',
    url: 'https://kimtaesung.kr',
    siteName: '김태성과 신안',
    images: [{ url: '/og-image.png', width: 1200, height: 630 }],
  },
};

// ❌ SmartAppBanner.tsx 컴포넌트 삭제 — useEffect 방식 사용하지 않음
```

> **App Store ID 확인 방법**: App Store Connect → 내 앱 → 앱 정보 → Apple ID 항목

#### Hero 컴포넌트
```typescript
// src/components/Hero.tsx
'use client';
import { Button } from '@/components/ui/button';

export default function Hero({ settings }: any) {
  return (
    <section className="bg-gradient-to-b from-[#1B3A6B] to-[#2d5aa0] text-white py-20 px-4">
      <div className="max-w-4xl mx-auto text-center">
        <h1 className="text-5xl font-bold mb-6">신안의 미래</h1>
        <p className="text-xl mb-8 opacity-90">{settings.description}</p>
        <div className="flex gap-4 justify-center">
          <Button className="bg-[#E8941A] hover:bg-[#d17a0f] text-white px-8 py-3">
            정책 보기
          </Button>
          <Button variant="outline" className="text-white border-white px-8 py-3">
            앱 다운로드
          </Button>
        </div>
      </div>
    </section>
  );
}
```

#### PolicyCard 컴포넌트
```typescript
// src/components/PolicyCard.tsx
import Image from 'next/image';
import { Card } from '@/components/ui/card';

export default function PolicyCard({ policy }: any) {
  return (
    <Card className="p-6 hover:shadow-lg transition-shadow">
      {policy.icon && (
        <Image
          src={policy.icon.url}
          alt={policy.title}
          width={80}
          height={80}
          className="mb-4"
        />
      )}
      <h3 className="text-xl font-bold mb-3 text-[#1B3A6B]">
        {policy.title}
      </h3>
      <p className="text-gray-600 line-clamp-3">{policy.description}</p>
    </Card>
  );
}
```

#### CountdownTimer 컴포넌트
```typescript
// src/components/CountdownTimer.tsx
'use client';
import { useEffect, useState } from 'react';

export default function CountdownTimer({ daysLeft }: { daysLeft: number }) {
  const [display, setDisplay] = useState(daysLeft);

  useEffect(() => {
    setDisplay(daysLeft);
  }, [daysLeft]);

  return (
    <section className="py-12 px-4 bg-white border-b-2 border-[#E8941A]">
      <div className="max-w-4xl mx-auto text-center">
        <p className="text-gray-600 mb-2">선거일까지</p>
        <div className="text-6xl font-bold text-[#1B3A6B] mb-2">
          D-{display}
        </div>
        <p className="text-gray-600">신안의 미래를 함께 만드는 날</p>
      </div>
    </section>
  );
}
```

### 4-4. Tailwind 커스터마이징
```css
/* src/app/globals.css */
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
  --color-primary: #1B3A6B;    /* 진파랑 */
  --color-accent: #E8941A;     /* 오렌지 */
}

.btn-primary {
  @apply px-6 py-3 bg-[#1B3A6B] text-white rounded-lg hover:bg-opacity-90 transition-all;
}

.btn-secondary {
  @apply px-6 py-3 bg-[#E8941A] text-white rounded-lg hover:bg-opacity-90 transition-all;
}

.card-hover {
  @apply hover:shadow-lg hover:scale-105 transition-transform;
}
```

### ✅ STEP 4 완료 조건
- [ ] http://localhost:3000 에서 홈페이지 렌더링됨
- [ ] Contentful 정책 데이터 표시됨 (더미 데이터 필요)
- [ ] 모바일 반응형 확인 (iPhone + Android)
- [ ] D-Day 카운터 작동함

---

## **STEP 5: 정책 상세 페이지** (Day 6 | 3시간)

```typescript
// src/app/policies/page.tsx
import { getPolicies } from '@/lib/contentful';
import { Card } from '@/components/ui/card';

export const revalidate = 3600;

export default async function PoliciesPage() {
  const policies = await getPolicies();

  return (
    <div className="py-16 px-4 max-w-4xl mx-auto">
      <h1 className="text-4xl font-bold mb-4">김태성의 정책</h1>
      <p className="text-gray-600 mb-12">
        신안군의 미래를 위한 6가지 핵심 정책입니다.
      </p>

      <div className="space-y-12">
        {policies.map((policy, idx) => (
          <Card key={policy.sys.id} className="p-8">
            <div className="flex items-start gap-6">
              {policy.fields.icon && (
                <img
                  src={policy.fields.icon.url}
                  alt={policy.fields.title}
                  className="w-20 h-20 flex-shrink-0"
                />
              )}
              <div className="flex-1">
                <h2 className="text-2xl font-bold mb-4 text-[#1B3A6B]">
                  정책 {idx + 1}: {policy.fields.title}
                </h2>
                <div className="prose prose-sm max-w-none mb-6">
                  {policy.fields.description}
                </div>
                {policy.fields.roadmap && (
                  <div className="bg-blue-50 p-4 rounded">
                    <h3 className="font-bold mb-2">로드맵</h3>
                    <p>{policy.fields.roadmap}</p>
                  </div>
                )}
              </div>
            </div>
          </Card>
        ))}
      </div>
    </div>
  );
}
```

### ✅ STEP 5 완료 조건
- [ ] /policies 페이지 작동
- [ ] 정책 6개 모두 표시됨
- [ ] 로드맵 섹션 렌더링됨

---

## **STEP 6: 뉴스 피드** (Day 6-7 | 3시간)

```typescript
// src/app/news/page.tsx
import { getNews } from '@/lib/contentful';
import Image from 'next/image';
import Link from 'next/link';
import { Card } from '@/components/ui/card';

export const revalidate = 1800; // 30분 ISR

export default async function NewsPage() {
  const news = await getNews(20);

  return (
    <div className="py-16 px-4 max-w-4xl mx-auto">
      <h1 className="text-4xl font-bold mb-12">최신 뉴스</h1>

      <div className="grid gap-6">
        {news.map((article) => (
          <Card key={article.sys.id} className="overflow-hidden card-hover">
            <div className="flex gap-4 p-6">
              {article.fields.featuredImage && (
                <Image
                  src={article.fields.featuredImage.url}
                  alt={article.fields.title}
                  width={200}
                  height={150}
                  className="rounded-lg object-cover flex-shrink-0"
                />
              )}
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-2">
                  <span className="text-sm font-semibold text-[#E8941A]">
                    {article.fields.category}
                  </span>
                  <span className="text-sm text-gray-500">
                    {new Date(article.fields.publishedAt).toLocaleDateString('ko-KR')}
                  </span>
                </div>
                <h3 className="text-lg font-bold mb-2 text-[#1B3A6B]">
                  {article.fields.title}
                </h3>
                <p className="text-gray-600 line-clamp-2 mb-3">
                  {article.fields.excerpt}
                </p>
                {article.fields.externalLink && (
                  <Link
                    href={article.fields.externalLink}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-[#1B3A6B] hover:underline font-semibold"
                  >
                    자세히 보기 →
                  </Link>
                )}
              </div>
            </div>
          </Card>
        ))}
      </div>
    </div>
  );
}
```

### ✅ STEP 6 완료 조건
- [ ] /news 페이지 작동
- [ ] 뉴스 카드 grid 레이아웃
- [ ] 외부 링크 클릭 가능
- [ ] 날짜 형식 한국어로 표시됨

---

## **STEP 7: 연락 페이지 (Formspree 사용)** (Day 7-8 | 2시간)

### 7-1. Formspree 가입
```
https://formspree.io → Sign Up (무료)
新 Form 생성
  Name: "Contact Form"
  Email: campaign@kimtaesung.kr
Form ID 복사: f/xxx
```

### 7-2. 연락 페이지 (fetch 비동기 방식 — 페이지 이동 없음)

> ⚠️ **중요**: `action="..."` 방식은 폼 제출 후 Formspree 외부 페이지로 이동합니다.  
> `fetch` 비동기 방식을 사용하면 페이지 이동 없이 Toast 메시지로 완료를 알립니다.

```typescript
// src/components/ContactForm.tsx
'use client';
import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';

const FORMSPREE_ID = 'YOUR_FORM_ID'; // Formspree에서 발급받은 ID

export default function ContactForm() {
  const [status, setStatus] = useState<'idle' | 'loading' | 'success' | 'error'>('idle');

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setStatus('loading');

    const formData = new FormData(e.currentTarget);

    try {
      const response = await fetch(`https://formspree.io/f/${FORMSPREE_ID}`, {
        method: 'POST',
        body: formData,
        headers: { Accept: 'application/json' },
      });

      if (response.ok) {
        setStatus('success');
        (e.target as HTMLFormElement).reset();
      } else {
        setStatus('error');
      }
    } catch {
      setStatus('error');
    }
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div>
        <label className="block text-sm font-semibold mb-2">이름</label>
        <Input name="name" type="text" placeholder="성명을 입력하세요" required />
      </div>

      <div>
        <label className="block text-sm font-semibold mb-2">이메일</label>
        <Input name="email" type="email" placeholder="이메일 주소" required />
      </div>

      <div>
        <label className="block text-sm font-semibold mb-2">메시지</label>
        <Textarea name="message" placeholder="의견을 자유롭게 작성해주세요" rows={6} required />
      </div>

      <Button
        type="submit"
        disabled={status === 'loading'}
        className="w-full bg-[#1B3A6B] hover:bg-[#0d2443] text-white py-3"
      >
        {status === 'loading' ? '전송 중...' : '메시지 전송'}
      </Button>

      {/* ✅ 페이지 이동 없이 결과 표시 */}
      {status === 'success' && (
        <div className="p-4 bg-green-50 border border-green-200 rounded text-green-700 text-center">
          ✅ 의견이 접수되었습니다. 감사합니다!
        </div>
      )}
      {status === 'error' && (
        <div className="p-4 bg-red-50 border border-red-200 rounded text-red-700 text-center">
          ❌ 전송에 실패했습니다. 잠시 후 다시 시도해주세요.
        </div>
      )}
    </form>
  );
}
```

```typescript
// src/app/contact/page.tsx
import ContactForm from '@/components/ContactForm';

export default function ContactPage() {
  return (
    <div className="py-16 px-4 max-w-2xl mx-auto">
      <h1 className="text-4xl font-bold mb-4">직접 연락하기</h1>
      <p className="text-gray-600 mb-12">의견과 제안은 캠프 발전의 원동력입니다.</p>
      <ContactForm />
      <div className="mt-16 pt-8 border-t space-y-4">
        <h3 className="font-bold text-lg">기타 연락처</h3>
        <p><span className="font-semibold">이메일:</span> campaign@kimtaesung.kr</p>
        <p><span className="font-semibold">전화:</span> 061-240-XXXX</p>
        <p><span className="font-semibold">주소:</span> 전라남도 신안군 신안읍</p>
      </div>
    </div>
  );
}
```

### ✅ STEP 7 완료 조건
- [ ] /contact 페이지 작동
- [ ] 폼 제출 후 **같은 페이지**에서 성공 메시지 표시됨
- [ ] campaign@kimtaesung.kr로 이메일 수신됨
- [ ] Formspree 대시보드에서 제출 기록 확인
- [ ] 에러 발생 시 에러 메시지 표시됨

**💡 주의**: Formspree Form ID는 공개해도 안전합니다 (CORS 안전성 내장)

---

## **STEP 8: GA4 분석 + Smart App Banner** (Day 8 | 2시간)

### 8-1. Google Analytics 4 설정

```
https://analytics.google.com
→ "새 속성 만들기"
→ 속성명: "kimtaesung.kr"
→ 데이터 스트림: "Web"
→ 웹 주소: https://kimtaesung.kr
→ 스트림 이름: "kimtaesung-web"

Measurement ID 복사: G-XXXXXXXXXX
.env.local에 저장:
NEXT_PUBLIC_GA_MEASUREMENT_ID=G-XXXXXXXXXX
```

### 8-2. GA4 통합 컴포넌트
```typescript
// src/app/layout.tsx에 추가
import { GoogleAnalytics } from '@next/third-parties/google';

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ko">
      <body>
        {/* ... */}
        <GoogleAnalytics gaId={process.env.NEXT_PUBLIC_GA_MEASUREMENT_ID!} />
      </body>
    </html>
  );
}
```

### 8-3. Smart App Banner — metadata 방식 (SSR 보장)

> ⚠️ **SmartAppBanner.tsx 컴포넌트 삭제** — `useEffect`로 meta 태그를 동적 삽입하면  
> iOS Safari가 초기 로딩 시 인식하지 못해 배너가 뜨지 않습니다.  
> Next.js `metadata` 객체를 사용하면 SSR 단계에서 HTML에 포함됩니다.

```typescript
// ✅ src/app/layout.tsx의 metadata에 통합 (STEP 4에서 이미 설정됨)
export const metadata: Metadata = {
  // ...기존 설정...

  // iOS Safari Smart App Banner
  // → <meta name="apple-itunes-app" content="app-id=1234567890"> 로 렌더링
  itunes: {
    appId: '1234567890',          // App Store Connect → 내 앱 → Apple ID
    appArgument: 'kimtaesung://', // 앱 내 딥링크 (옵션)
  },
  // Android 커스텀 메타 태그
  // → <meta name="google-play-app" content="app-id=..."> 로 렌더링
  other: {
    'google-play-app': 'app-id=com.kimtaesung.sinanjuso',
  },
};

// ❌ 아래 컴포넌트 방식은 사용하지 않음
// SmartAppBanner.tsx 파일 생성 불필요
```

**App Store ID 확인 방법**
```
App Store Connect → 내 앱 선택 → 앱 정보 → Apple ID 항목 숫자
예: 1234567890
```

### 8-4. 이벤트 추적 (옵션)
```typescript
// GA4 이벤트 추적 예시
'use client';
import { useEffect } from 'react';

export function trackEvent(eventName: string, eventParams?: Record<string, any>) {
  if (typeof window !== 'undefined' && window.gtag) {
    window.gtag('event', eventName, eventParams);
  }
}

// 사용 예
// trackEvent('view_policy', { policy_id: '1' });
```

### ✅ STEP 8 완료 조건
- [ ] Google Analytics 4 등록됨
- [ ] https://analytics.google.com 에서 데이터 수신 확인
- [ ] 모바일 브라우저에서 앱 배너 표시 확인 (iOS/Android)
- [ ] OG 이미지 및 메타 태그 설정됨

---

## **STEP 9: Vercel 배포** (Day 9 | 1시간)

### 9-1. GitHub에 코드 푸시
```bash
git add .
git commit -m "Complete: website development

- Shadcn/ui components
- Contentful integration
- Formspree contact form
- GA4 analytics
- Smart app banner
"
git push origin main
```

### 9-2. Vercel 배포 (자동)

**Vercel 대시보드 (https://vercel.com)**
```
1. "Add New..." → "Project"
2. GitHub 저장소 검색: "sinanjuso-web"
3. 클릭하면 자동 배포 시작
4. 환경 변수 입력:
   - NEXT_PUBLIC_CONTENTFUL_SPACE_ID
   - NEXT_PUBLIC_CONTENTFUL_ACCESS_TOKEN
   - NEXT_PUBLIC_GA_MEASUREMENT_ID
5. 배포 완료 (약 2분)
```

### 9-3. 커스텀 도메인 연결

**Gabia (도메인 등록사)**
```
대시보드 → kimtaesung.kr → DNS 관리

Vercel에서 제공하는 CNAME 레코드 추가:
호스트: www
타입: CNAME
값: cname.vercel-dns.com

또는 nameserver 변경:
ns1.vercel-dns.com
ns2.vercel-dns.com
```

**Vercel 대시보드**
```
Project Settings → Domains
"Add Domain" → kimtaesung.kr 입력
자동으로 DNS 설정 감지
```

### ✅ STEP 9 완료 조건
- [ ] https://kimtaesung.kr 접속 가능
- [ ] HTTPS 작동 (녹색 자물쇠)
- [ ] 모든 페이지 정상 로딩
- [ ] Vercel 대시보드에서 배포 로그 확인

**💡 팁**: 매번 `git push`할 때마다 자동으로 배포됨 (무중단)

---

## **STEP 10: 최적화 + SEO** (Day 9-10 | 2시간)

### 10-1. Sitemap 생성
```typescript
// src/app/sitemap.ts
import { getPolicies, getNews } from '@/lib/contentful';

export default async function sitemap() {
  const policies = await getPolicies();
  const news = await getNews(50);

  const baseUrl = 'https://kimtaesung.kr';

  return [
    {
      url: baseUrl,
      lastModified: new Date(),
      changeFrequency: 'daily',
      priority: 1,
    },
    {
      url: `${baseUrl}/policies`,
      lastModified: new Date(),
      changeFrequency: 'weekly',
      priority: 0.8,
    },
    {
      url: `${baseUrl}/news`,
      lastModified: new Date(),
      changeFrequency: 'daily',
      priority: 0.8,
    },
    {
      url: `${baseUrl}/contact`,
      lastModified: new Date(),
      changeFrequency: 'monthly',
      priority: 0.5,
    },
  ];
}
```

### 10-2. robots.txt
```
// public/robots.txt
User-agent: *
Allow: /
Disallow: /api/

Sitemap: https://kimtaesung.kr/sitemap.xml
```

### 10-3. 성능 측정
```bash
# 빌드 후 성능 분석
npm run build
npm run start

# https://www.webpagetest.org 방문
# kimtaesung.kr 테스트
# 목표: Lighthouse 85+ 점수
```

### 10-4. Google Search Console 등록
```
https://search.google.com/search-console
→ URL 접두어: https://kimtaesung.kr
→ DNS TXT 레코드 추가 (Gabia에서)
→ 확인 대기 (1-3시간)
```

### ✅ STEP 10 완료 조건
- [ ] /sitemap.xml 작동
- [ ] Lighthouse 점수 85 이상
- [ ] Google Search Console 확인됨
- [ ] robots.txt 설정됨

---

## **STEP 11: Contentful 콘텐츠 입력** (Day 11-14 | 4시간)

### 11-1. 정책 6개 입력 (각각 15분)

Contentful Dashboard → Content → Policy

```
정책 1: 
- title: "투명한 정치, 신안의 첫걸음"
- description: [상세 설명]
- icon: [정책 아이콘 이미지]
- roadmap: "2026 6월 실행 → 8월 평가"
- order: 1

... (정책 2-6)
```

### 11-2. 초기 뉴스 5-10개 입력 (각각 10분)

```
뉴스 1:
- title: "김태성 신안군수 예비후보, 신안의 미래 정책 발표"
- excerpt: "신안군의 발전을 위한 6가지 핵심 정책을 발표했습니다."
- content: [기사 본문]
- featuredImage: [썸네일]
- publishedAt: 2026-04-18
- category: "보도자료"

... (뉴스 2-10)
```

### 11-3. 전역 설정 1개 입력

```
Settings:
- siteName: "김태성과 신안"
- description: "신안군수 예비후보 김태성의 공식 웹사이트"
- daysUntilElection: 47
- contactEmail: "campaign@kimtaesung.kr"
- contactPhone: "061-240-XXXX"
- address: "전라남도 신안군 신안읍 XX로"
- socialLinks: {
    "instagram": "https://instagram.com/...",
    "youtube": "https://youtube.com/...",
    "facebook": "https://facebook.com/..."
  }
```

### ✅ STEP 11 완료 조건
- [ ] Contentful에 정책 6개 입력됨
- [ ] 뉴스 5개 이상 입력됨
- [ ] 전역 설정 입력됨
- [ ] 웹사이트에서 모두 표시됨

---

## **STEP 12: 최종 테스트** (Day 15-16 | 4시간)

### 12-1. 브라우저 호환성
```
[ ] Chrome (최신)
[ ] Safari (최신)
[ ] Firefox (최신)
[ ] Edge (최신)
```

### 12-2. 모바일 테스트
```
[ ] iPhone 12/14/16 (Safari)
[ ] Galaxy S20+ (Chrome)
[ ] 세로 모드 반응형
[ ] 가로 모드 반응형
```

### 12-3. 기능 체크리스트
```
[ ] 모든 링크 작동
[ ] 폼 제출 테스트 (이메일 수신 확인)
[ ] 이미지 로딩 속도
[ ] 외부 링크 (SNS, 앱 스토어)
[ ] GA4 이벤트 추적
[ ] D-Day 카운터 정확성
```

### 12-4. SEO 검증
```
[ ] Meta tags 확인 (개발자 도구)
[ ] Open Graph 이미지 표시 (SNS 공유 테스트)
[ ] Sitemap 제출 (Google Search Console)
[ ] robots.txt 유효성
```

### ✅ STEP 12 완료 조건
- [ ] 모든 체크리스트 통과
- [ ] 404 에러 없음
- [ ] 콘솔 경고 최소화
- [ ] Lighthouse 85+ 유지

---

## **STEP 13: 마케팅 준비** (Day 17-25 | 병렬 진행)

### 13-1. 콘텐츠 준비
```
[ ] OG 이미지 (1200x630) — 웹사이트 공식 이미지
[ ] SNS 썸네일 (1080x1080) — 인스타그램용
[ ] 정책 상세 설명 6개 — 웹사이트 콘텐츠
[ ] 뉴스 기사 10개 — 선거일까지 정기 업데이트
[ ] 연락처 정보 확인
```

### 13-2. SNS 전략
```
[ ] 인스타그램 계정 연결
[ ] 유튜브 채널 링크 확인
[ ] 페이스북 페이지 생성
[ ] 네이버 블로그 (옵션)
[ ] 카카오톡 채널 (옵션)
```

### 13-3. QR 코드 생성
```
웹사이트: https://kimtaesung.kr
QR 코드 생성: https://qr-code-generator.com
용도: 전단지, 포스터, SNS 바이오
```

### 13-4. 이메일 뉴스레터 준비 (향후)
```
구독자 수집 페이지 (간단한 이메일 입력 폼)
주간 뉴스레터 템플릿
자동 발송 설정 (Mailchimp 등)
```

### ✅ STEP 13 완료 조건
- [ ] OG 이미지 + SNS 이미지 준비됨
- [ ] SNS 링크 모두 연결됨
- [ ] QR 코드 생성됨
- [ ] 초기 뉴스 10개 준비됨

---

## **STEP 14: 운영 전략** (Day 26-47)

### 14-1. 일일 운영
```
매일 1시간
├─ GA4 분석 검토 (어떤 정책이 인기인가?)
├─ 뉴스 피드 업데이트 (주 3회)
└─ SNS 포스팅 (주 5회)
```

### 14-2. 주간 운영
```
매주 2시간
├─ Contentful 콘텐츠 추가/수정
├─ 앱 심사 결과 확인
├─ 성능 메트릭 리뷰 (Vercel + GA4)
└─ 캠프 피드백 반영
```

### 14-3. 성능 모니터링
```
Vercel Analytics
├─ 월 방문자 수
├─ 평균 응답 시간
├─ 에러율
└─ 지역별 트래픽

Google Analytics
├─ 정책별 관심도
├─ 모바일 vs PC 비율
├─ 뉴스 클릭율
└─ 앱 다운로드 전환율
```

### 14-4. 긴급 대응
```
만약 문제 발생 시:
1. Vercel 배포 로그 확인
2. Contentful API 상태 확인
3. 롤백 (이전 배포로 복구)
4. GitHub issue 기록
```

### ✅ STEP 14 완료 조건
- [ ] 일일 운영 체계 확립
- [ ] 성능 모니터링 대시보드 설정됨
- [ ] 캠프 팀과 운영 일정 조율됨

---

# 📊 최종 일정 요약

| Week | Task | 시간 | 상태 |
|------|------|------|------|
| **1** | STEP 1-3: 환경 + Contentful | 7시간 | |
| **2** | STEP 4-6: 홈/정책/뉴스 페이지 | 12시간 | |
| **3** | STEP 7-10: 연락/배포/최적화 | 8시간 | |
| **4** | STEP 11-12: 콘텐츠 + 테스트 | 8시간 | |
| **5-6** | STEP 13-14: 마케팅 + 운영 | 버퍼 | |
| **합계** | | **35시간** | |

---

# 🎯 주요 체크포인트

```
Day 7: STEP 1-3 완료 (환경 셋업)
  ✓ Vercel에 배포됨
  ✓ Contentful 연동됨
  ✓ localhost에서 작동

Day 14: STEP 4-6 완료 (핵심 페이지)
  ✓ 홈/정책/뉴스 페이지 완성
  ✓ Contentful 콘텐츠 입력됨
  ✓ kimtaesung.kr 라이브

Day 21: STEP 7-10 완료 (배포 + 최적화)
  ✓ 연락 폼 작동
  ✓ GA4 추적 시작
  ✓ Smart App Banner 작동
  ✓ SEO 설정 완료

Day 25: STEP 11-12 완료 (콘텐츠 + 테스트)
  ✓ 뉴스 10개 이상 업로드
  ✓ 최종 QA 통과
  ✓ 마케팅 자료 준비

Day 47: 선거일
  ✓ 웹사이트 안정적 운영
  ✓ 실시간 데이터 기반 마케팅
```

---

# 💡 성공 팁

### 1️⃣ 시간 절약 팁
- **Shadcn/ui**: 버튼, 카드 등 미리 만들어진 컴포넌트 사용
- **ISR 캐싱**: 자주 바뀌지 않는 페이지는 3600초(1시간) 캐시
- **GitHub Actions**: 자동 배포로 수동 작업 제거
- **Contentful 템플릿**: 뉴스 작성 시간 단축

### 2️⃣ 에러 대응
- 문제 발생 → Vercel 배포 로그 먼저 확인
- Contentful API 에러 → 환경 변수 재확인
- 배포 실패 → GitHub 커밋 메시지 확인 (구문 오류)

### 3️⃣ 콘텐츠 관리
- 매주 정책/뉴스 3-5개씩 업데이트
- GA4로 인기 있는 정책 파악 후 강조
- SNS와 웹사이트 콘텐츠 동기화

### 4️⃣ 성능 최적화
- 이미지는 1MB 이하 (WebP 포맷 추천)
- JavaScript 번들 사이즈 모니터링 (Vercel Analytics)
- 모바일 우선 설계

---

# 🚀 지금 바로 시작하기

```bash
# STEP 1 실행
npx create-next-app@latest sinanjuso-web \
  --typescript --tailwind --eslint --src-dir --app
cd sinanjuso-web

# ✅ Shadcn/ui 최신 명령어 (2024 이후 공식 변경)
# ❌ 구버전: npx shadcn-ui@latest init (패키지명 변경됨)
npx shadcn@latest init

# Contentful 패키지
npm install contentful axios

# 개발 시작
npm run dev

# 완료! 이제 Contentful 가입으로 STEP 2 시작
```

---

**작성자**: Claude Code  
**최종 수정**: 2026-04-18 (v2 — 기술 수정본)  
**기반 피드백**:  
- v1: 제미나이 1차 피드백 (Vercel/Formspree/Shadcn/GA4/Smart App Banner 반영)  
- v2: 제미나이 2차 피드백 (Smart App Banner SSR 수정 / Formspree fetch 비동기 / shadcn 명령어 최신화)

*이 문서는 프로젝트 진행 중 언제든 업데이트될 수 있습니다.*
