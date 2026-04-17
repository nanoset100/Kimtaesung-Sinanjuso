import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/contact_data.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

// ──────────────────────────────────────────────────────────
// 앱스토어 정책 준수 (CLAUDE.md):
//   url_launcher 외부 앱 열기만 허용
//   전화·이메일·카카오톡 모두 외부로 처리
// ──────────────────────────────────────────────────────────
class ContactButtonList extends StatelessWidget {
  final List<ContactItem> contacts;

  const ContactButtonList({super.key, required this.contacts});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: contacts
          .asMap()
          .entries
          .map(
            (e) => ContactButtonTile(
              item: e.value,
              isLast: e.key == contacts.length - 1,
            ),
          )
          .toList(),
    );
  }
}

class ContactButtonTile extends StatelessWidget {
  final ContactItem item;
  final bool isLast;

  const ContactButtonTile({
    super.key,
    required this.item,
    required this.isLast,
  });

  Future<void> _launch(BuildContext context) async {
    final uri = Uri.parse(item.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.label} 앱을 열 수 없습니다')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _launch(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: AppColors.border, width: 0.5),
                ),
        ),
        child: Row(
          children: [
            // 아이콘 원
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.iconBgColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(item.icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),

            // 레이블 + 값
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: AppTypography.sizeMd,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.value,
                    style: const TextStyle(
                      fontSize: AppTypography.sizeSm,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // 외부 링크 아이콘
            const Icon(
              Icons.open_in_new,
              color: AppColors.primaryMid,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
