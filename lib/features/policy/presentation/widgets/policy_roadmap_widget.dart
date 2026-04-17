import 'package:flutter/material.dart';
import '../../domain/entities/policy_entity.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class PolicyRoadmapWidget extends StatelessWidget {
  final List<RoadmapStep> steps;

  const PolicyRoadmapWidget({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: steps
          .map((step) => _RoadmapStepRow(step: step, isLast: step == steps.last))
          .toList(),
    );
  }
}

class _RoadmapStepRow extends StatelessWidget {
  final RoadmapStep step;
  final bool isLast;

  const _RoadmapStepRow({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 왼쪽: 번호 원 + 연결선
          SizedBox(
            width: 32,
            child: Column(
              children: [
                // 번호 원
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${step.step}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AppTypography.sizeXs,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                // 연결선 (마지막 아이템 제외)
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.primaryLight,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // 오른쪽: 텍스트
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    step.title,
                    style: const TextStyle(
                      fontSize: AppTypography.sizeMd,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.subtitle,
                    style: const TextStyle(
                      fontSize: AppTypography.sizeSm,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
