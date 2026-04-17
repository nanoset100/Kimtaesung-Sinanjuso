import 'package:flutter/material.dart';

import '../../data/models/survey_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

// ── 실시간 투표 결과 막대 차트 ─────────────────────────────
// StreamBuilder와 연동하여 Firestore 갱신 시 자동 리빌드
class VoteChartWidget extends StatelessWidget {
  final SurveyQuestion question;
  final SurveyAggregate aggregate;
  final String? highlightOptionId;  // 내가 선택한 항목 강조

  const VoteChartWidget({
    super.key,
    required this.question,
    required this.aggregate,
    this.highlightOptionId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 참여자 수
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              const Icon(Icons.people_outline,
                  size: 16, color: AppColors.primaryMid),
              const SizedBox(width: 4),
              Text(
                '총 ${aggregate.total}명 참여',
                style: const TextStyle(
                  fontSize: AppTypography.sizeSm,
                  color: AppColors.primaryMid,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // 막대 차트 목록
        ...question.options.map((option) {
          final count = aggregate.counts[option.id] ?? 0;
          final pct = aggregate.percentOf(option.id);
          final isHighlighted = highlightOptionId == option.id;

          return _ChartBar(
            label: option.text,
            count: count,
            percent: pct,
            isHighlighted: isHighlighted,
          );
        }),
      ],
    );
  }
}

// ── 개별 막대 항목 ────────────────────────────────────────
class _ChartBar extends StatelessWidget {
  final String label;
  final int count;
  final double percent;
  final bool isHighlighted;

  const _ChartBar({
    required this.label,
    required this.count,
    required this.percent,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    final pctText = '${(percent * 100).round()}%';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 레이블 행
          Row(
            children: [
              if (isHighlighted) ...[
                const Icon(Icons.check_circle,
                    size: 14, color: AppColors.success),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: AppTypography.sizeSm,
                    fontWeight: isHighlighted
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: isHighlighted
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '$count명  $pctText',
                style: TextStyle(
                  fontSize: AppTypography.sizeXs,
                  fontWeight: FontWeight.w700,
                  color: isHighlighted
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // 막대 트랙
          LayoutBuilder(
            builder: (_, constraints) {
              return Stack(
                children: [
                  // 배경
                  Container(
                    height: 14,
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  // 채워진 바
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    height: 14,
                    width: constraints.maxWidth * percent,
                    decoration: BoxDecoration(
                      color: isHighlighted
                          ? AppColors.primary
                          : AppColors.primaryMid,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
