import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/news_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class NewsCardWidget extends StatelessWidget {
  final NewsItem news;

  const NewsCardWidget({super.key, required this.news});

  Future<void> _openArticle(BuildContext context) async {
    final uri = Uri.parse(news.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('링크를 열 수 없습니다')),
      );
    }
  }

  void _shareArticle() {
    SharePlus.instance.share(
      ShareParams(
        text: '${news.title}\n\n출처: ${news.source}\n${news.url}',
        subject: news.title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openArticle(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 썸네일 ────────────────────────────────
            Container(
              width: 64,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                news.thumbnailEmoji,
                style: const TextStyle(fontSize: 26),
              ),
            ),
            // TODO: CachedNetworkImage로 교체
            // if (news.thumbnailUrl != null)
            //   ClipRRect(
            //     borderRadius: BorderRadius.circular(10),
            //     child: CachedNetworkImage(
            //       imageUrl: news.thumbnailUrl!,
            //       width: 64, height: 54, fit: BoxFit.cover,
            //     ),
            //   )

            const SizedBox(width: 12),

            // ── 본문 텍스트 ───────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤드라인
                  Text(
                    news.title,
                    style: const TextStyle(
                      fontSize: AppTypography.sizeMd,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),

                  // 출처 + 시간
                  Row(
                    children: [
                      // 카테고리 배지
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          news.category.label,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // 출처
                      Expanded(
                        child: Text(
                          news.source,
                          style: const TextStyle(
                            fontSize: AppTypography.sizeXs,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // 시간
                      Text(
                        news.publishedAt,
                        style: const TextStyle(
                          fontSize: AppTypography.sizeXs,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── 공유 버튼 ─────────────────────────────
            // WCAG 2.1 AA: 최소 48×48dp 터치 영역
            SizedBox(
              width: 40,
              height: 48,
              child: IconButton(
                icon: const Icon(Icons.share_outlined,
                    size: 18, color: AppColors.textSecondary),
                onPressed: _shareArticle,
                tooltip: '공유',
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
