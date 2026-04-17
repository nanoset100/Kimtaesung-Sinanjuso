import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../data/models/policy_model.dart';
import 'policy_detail_screen.dart';
import 'widgets/policy_card_widget.dart';

class PolicyListScreen extends StatelessWidget {
  const PolicyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final policies = PolicyRepository.policies;

    return Scaffold(
      body: Column(
        children: [
          // ── 미니 후보 프로필 배너 ──────────────────────
          const _MiniCandidateBanner(),

          // ── 섹션 타이틀 ───────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
            color: AppColors.surface,
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '핵심 정책 6가지',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '탭하면 자세히 볼 수 있어요',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 0.5, color: AppColors.border),

          // ── 정책 카드 목록 ─────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: policies.length,
              itemBuilder: (context, index) {
                final policy = policies[index];
                return PolicyCardWidget(
                  policy: policy,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PolicyDetailScreen(policy: policy),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── 후보 배너 카드 ─────────────────────────────────────────
class _MiniCandidateBanner extends StatelessWidget {
  const _MiniCandidateBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── 흰 카드 ───────────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFE8F2FF)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 후보 사진 (깔끔한 증명사진)
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        width: 2,
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
                  const SizedBox(width: 14),
                  // 이름 + 슬로건
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '김태성',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '신안군수 예비후보',
                          style: TextStyle(
                            color: AppColors.primary.withValues(alpha: 0.65),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '소득 늘리고, 일자리 만들고,\n약속지키는 군수',
                          style: TextStyle(
                            color: AppColors.primary.withValues(alpha: 0.75),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // ── 파란 하단 테두리 라인 ─────────────────────
            Container(
              height: 3,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
