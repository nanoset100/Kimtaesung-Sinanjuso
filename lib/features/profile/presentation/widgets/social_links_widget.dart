import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/profile_data.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

// ──────────────────────────────────────────────────────────
// 앱스토어 정책 준수 (CLAUDE.md):
//   - url_launcher로 외부 앱 열기만 허용
//   - 앱 내 결제·기부금 수집 금지 → 외부 링크 안내만
// ──────────────────────────────────────────────────────────
class SocialLinksWidget extends StatelessWidget {
  final List<SnsLink> links;

  const SocialLinksWidget({super.key, required this.links});

  Future<void> _openUrl(BuildContext context, String urlStr) async {
    final uri = Uri.parse(urlStr);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('링크를 열 수 없습니다')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: links
          .map((link) => _SnsButton(
                link: link,
                onTap: () => _openUrl(context, link.url),
              ))
          .toList(),
    );
  }
}

class _SnsButton extends StatelessWidget {
  final SnsLink link;
  final VoidCallback onTap;

  const _SnsButton({required this.link, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // 아이콘 원형 버튼 — WCAG 2.1 AA: 최소 48×48dp
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: link.bgColor,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            alignment: Alignment.center,
            child: Text(link.emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 5),
          Text(
            link.label,
            style: const TextStyle(
              fontSize: AppTypography.sizeXs,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
