import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../data/profile_data.dart';
import '../../policy/data/models/policy_model.dart';
import '../../policy/presentation/policy_detail_screen.dart';
import 'widgets/career_timeline_widget.dart';
import 'widgets/social_links_widget.dart';

// ──────────────────────────────────────────────────────────
// 프로필 화면 — 랜딩 페이지 (P0)
//   • Hero 배너: 후보 사진·이름·직책·슬로건
//   • SNS 링크: url_launcher 외부 앱 열기
//   • 경력 타임라인: Hive 오프라인 캐시
//   • 정책 칩 6개: 탭 → 해당 정책 상세로 이동
// ──────────────────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const String _cacheBoxName = 'profile_cache';
  static const String _cacheKey = 'career_items';

  List<CareerItem> _careerItems = [];
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // Hive 오프라인 캐시 로직
  // 1. Hive에 캐시가 있으면 즉시 표시 (오프라인 포함)
  // 2. 정적 데이터(또는 미래 API) 로드 후 캐시 갱신
  Future<void> _loadProfile() async {
    // 캐시 박스 열기
    if (!Hive.isBoxOpen(_cacheBoxName)) {
      await Hive.openBox<String>(_cacheBoxName);
    }
    final box = Hive.box<String>(_cacheBoxName);

    final cached = box.get(_cacheKey);
    if (cached != null) {
      // 캐시 히트: JSON 복원
      final List<dynamic> rawList = jsonDecode(cached) as List<dynamic>;
      if (mounted) {
        setState(() {
          _careerItems = rawList
              .map((e) => CareerItem.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList();
          _isLoaded = true;
        });
      }
    }

    // TODO: 실제 API 호출로 대체 (Firebase/REST)
    // 현재는 정적 데이터 사용 — 캐시 갱신
    final freshItems = CandidateProfile.career;
    final encoded = jsonEncode(freshItems.map((e) => e.toMap()).toList());
    await box.put(_cacheKey, encoded);

    if (mounted) {
      setState(() {
        _careerItems = freshItems;
        _isLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoaded
          ? _buildContent(context)
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildContent(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ── Hero SliverAppBar ───────────────────────────
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          flexibleSpace: FlexibleSpaceBar(
            background: _HeroBanner(),
          ),
        ),

        // ── 스크롤 본문 ─────────────────────────────────
        SliverToBoxAdapter(
          child: Column(
            children: [
              // SNS 링크
              _SectionCard(
                title: '🔗 SNS & 공식 채널',
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SocialLinksWidget(links: CandidateProfile.snsLinks),
                ),
              ),

              // 경력 타임라인
              _SectionCard(
                title: '📋 주요 경력',
                child: CareerTimelineWidget(items: _careerItems),
              ),

              // 핵심 정책 칩 6개
              _SectionCard(
                title: '📌 핵심 정책',
                trailing: TextButton(
                  onPressed: () {
                    // 정책 탭은 IndexedStack으로 관리됨 — 상위 MainShell에 알림 필요
                    // TODO: GoRouter 도입 시 context.go('/policy')로 개선
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('하단 "정책" 탭을 눌러 전체 공약을 확인하세요')),
                    );
                  },
                  child: const Text(
                    '모두 보기 ›',
                    style: TextStyle(
                      fontSize: AppTypography.sizeXs,
                      color: AppColors.primaryMid,
                    ),
                  ),
                ),
                // 2열 고정 그리드 — 모든 칩 동일 너비
                child: Column(
                  children: List.generate(
                    (CandidateProfile.policyChips.length / 2).ceil(),
                    (rowIndex) {
                      final left = rowIndex * 2;
                      final right = left + 1;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            _buildPolicyChip(context, left),
                            const SizedBox(width: 8),
                            if (right < CandidateProfile.policyChips.length)
                              _buildPolicyChip(context, right)
                            else
                              const Expanded(child: SizedBox()),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  // 정책 칩 빌더 — Expanded로 동일 너비 보장
  Widget _buildPolicyChip(BuildContext context, int index) {
    final chip = CandidateProfile.policyChips[index];
    final policy = PolicyRepository.policies[index];
    return Expanded(
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PolicyDetailScreen(policy: policy),
          ),
        ),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            '${chip['emoji']} ${chip['label']}',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: AppTypography.sizeSm,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// ── Hero 배너 위젯 ────────────────────────────────────────
class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryMid],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 12),

            // 후보 사진 (원형 클립)
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: Container(
                  color: Colors.white,
                  child: Image.asset(
                    'assets/images/candidate_face.png',
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 이름
            const Text(
              AppStrings.candidateName,
              style: TextStyle(
                color: Colors.white,
                fontSize: AppTypography.size2xl,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),

            // 소속 + 지역
            Text(
              '${AppStrings.candidateTitle} · ${CandidateProfile.district}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: AppTypography.sizeSm,
              ),
            ),
            const SizedBox(height: 8),

            // 배지
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                CandidateProfile.badge,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppTypography.sizeXs,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 공통 섹션 카드 ────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.border.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: AppTypography.sizeMd,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                if (trailing != null) ...[
                  const Spacer(),
                  trailing!,
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.primaryLight),

          // 본문
          Padding(
            padding: const EdgeInsets.all(14),
            child: child,
          ),
        ],
      ),
    );
  }
}
