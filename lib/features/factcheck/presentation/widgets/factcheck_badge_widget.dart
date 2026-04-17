import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/factcheck_data.dart';

// ── 팩트체크 배지 (GREEN·YELLOW·RED) ─────────────────────
class FactCheckBadge extends StatelessWidget {
  final FactRating rating;
  final bool large;

  const FactCheckBadge({
    super.key,
    required this.rating,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 12 : 8,
        vertical: large ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: rating.bgColor,
        borderRadius: BorderRadius.circular(large ? 8 : 6),
        border: Border.all(
          color: rating.color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            rating.icon,
            size: large ? 16 : 13,
            color: rating.color,
          ),
          const SizedBox(width: 4),
          Text(
            rating.label,
            style: TextStyle(
              fontSize: large ? AppTypography.sizeSm : AppTypography.sizeXs,
              fontWeight: FontWeight.w700,
              color: rating.color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 팩트체크 카드 ─────────────────────────────────────────
class FactCheckCard extends StatelessWidget {
  final FactCheckItem item;
  final VoidCallback? onSourceTap;

  const FactCheckCard({
    super.key,
    required this.item,
    this.onSourceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.rating.color.withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: item.rating.color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 헤더 ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            decoration: BoxDecoration(
              color: item.rating.bgColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                // 카테고리 칩
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.category,
                    style: const TextStyle(
                      fontSize: AppTypography.sizeXs,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                FactCheckBadge(rating: item.rating),
              ],
            ),
          ),

          // ── 주장 내용 ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.rating.emoji,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.claim,
                    style: const TextStyle(
                      fontSize: AppTypography.sizeMd,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── 판정 요약 ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item.rating.bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '📌 ${item.verdict}',
                style: TextStyle(
                  fontSize: AppTypography.sizeSm,
                  fontWeight: FontWeight.w600,
                  color: item.rating.color,
                  height: 1.4,
                ),
              ),
            ),
          ),

          // ── 상세 설명 ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: Text(
              item.detail,
              style: const TextStyle(
                fontSize: AppTypography.sizeSm,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ),

          // ── 출처 & 날짜 ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Row(
              children: [
                const Icon(Icons.link, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Expanded(
                  // WCAG 2.1 AA: 최소 48dp 터치 영역 보장
                  child: GestureDetector(
                    onTap: onSourceTap,
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 48),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        item.source,
                        style: const TextStyle(
                          fontSize: AppTypography.sizeXs,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${item.checkedAt.month}/${item.checkedAt.day} 확인',
                  style: const TextStyle(
                    fontSize: AppTypography.sizeXs,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
