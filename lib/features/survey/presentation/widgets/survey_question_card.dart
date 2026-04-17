import 'package:flutter/material.dart';

import '../../data/models/survey_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

// 설문 문항 카드 — 라디오 선택 UI
class SurveyQuestionCard extends StatelessWidget {
  final SurveyQuestion question;
  final String? selectedOptionId;   // null = 미선택
  final bool isSubmitted;           // 제출 완료 시 비활성화
  final ValueChanged<String> onOptionSelected;

  const SurveyQuestionCard({
    super.key,
    required this.question,
    required this.selectedOptionId,
    required this.isSubmitted,
    required this.onOptionSelected,
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
            color: AppColors.border.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 문항 헤더 ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Text(
              question.question,
              style: const TextStyle(
                fontSize: AppTypography.sizeMd,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // ── 선택지 목록 ────────────────────────────
          ...question.options.asMap().entries.map((e) {
            final option = e.value;
            final isSelected = selectedOptionId == option.id;
            final isLast = e.key == question.options.length - 1;

            return _OptionTile(
              option: option,
              isSelected: isSelected,
              isSubmitted: isSubmitted,
              isLast: isLast,
              onTap: isSubmitted
                  ? null
                  : () => onOptionSelected(option.id),
            );
          }),

          // ── 익명 안내 ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Text(
              '※ 익명 참여 · 개인정보 수집 없음',
              style: TextStyle(
                fontSize: AppTypography.sizeXs,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 개별 선택지 타일 ──────────────────────────────────────
class _OptionTile extends StatelessWidget {
  final SurveyOption option;
  final bool isSelected;
  final bool isSubmitted;
  final bool isLast;
  final VoidCallback? onTap;

  const _OptionTile({
    required this.option,
    required this.isSelected,
    required this.isSubmitted,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primaryMid : AppColors.border,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // 라디오 원
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryMid
                      : AppColors.border,
                  width: isSelected ? 2 : 1.5,
                ),
                color: isSelected ? AppColors.primaryMid : Colors.transparent,
              ),
              alignment: Alignment.center,
              child: isSelected
                  ? Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // 선택지 텍스트
            Expanded(
              child: Text(
                option.text,
                style: TextStyle(
                  fontSize: AppTypography.sizeMd,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
