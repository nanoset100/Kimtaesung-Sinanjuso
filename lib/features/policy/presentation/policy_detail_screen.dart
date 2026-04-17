import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../domain/entities/policy_entity.dart';
import 'widgets/policy_roadmap_widget.dart';
import 'widgets/policy_rating_widget.dart';

class PolicyDetailScreen extends StatelessWidget {
  final PolicyEntity policy;

  const PolicyDetailScreen({super.key, required this.policy});

  void _sharePolicy(BuildContext context) {
    SharePlus.instance.share(
      ShareParams(
        text: '김태성 신안군수 예비후보 정책: ${policy.title}\n${policy.subtitle}\n\n${policy.background}',
        subject: '김태성 정책 — ${policy.title}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── 그라데이션 Hero AppBar ──────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                tooltip: AppStrings.share,
                onPressed: () => _sharePolicy(context),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryMid],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 56, 16, 16),
                    child: Row(
                      children: [
                        // 이모지 아이콘 박스
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            policy.emoji,
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // 제목 + 부제목
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                policy.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: AppTypography.sizeXl,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                policy.subtitle,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: AppTypography.sizeSm,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── 스크롤 본문 ────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              children: [
                // 정책 배경
                _DetailBlock(
                  icon: Icons.info_outline,
                  title: '정책 배경',
                  child: Text(
                    policy.background,
                    style: const TextStyle(
                      fontSize: AppTypography.sizeMd,
                      color: AppColors.textPrimary,
                      height: 1.7,
                    ),
                  ),
                ),

                // 기대 효과
                _DetailBlock(
                  icon: Icons.flag_outlined,
                  title: '기대 효과',
                  child: Text(
                    policy.goals,
                    style: const TextStyle(
                      fontSize: AppTypography.sizeMd,
                      color: AppColors.textPrimary,
                      height: 1.7,
                    ),
                  ),
                ),

                // 3대 추진 전략 (로드맵)
                _DetailBlock(
                  icon: Icons.route_outlined,
                  title: '3대 추진 전략',
                  child: PolicyRoadmapWidget(steps: policy.roadmap),
                ),

                // 별점 평가
                _DetailBlock(
                  icon: Icons.star_outline,
                  title: '이 정책을 평가해주세요',
                  child: PolicyRatingWidget(policyId: policy.id),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),

      // 하단 액션 버튼
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              // 공유하기
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _sharePolicy(context),
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text(AppStrings.share),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(48, 52),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 의견 남기기 (연락 화면으로)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: 소통 탭으로 이동 또는 ContactScreen push
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('소통 탭에서 의견을 남겨주세요')),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('의견 제출'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(48, 52),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 공통 섹션 블록 위젯 ──────────────────────────────────
class _DetailBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _DetailBlock({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.border.withValues(alpha: 0.5),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 섹션 헤더
            Row(
              children: [
                Icon(icon, color: AppColors.accent, size: 18),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: AppTypography.sizeMd,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
