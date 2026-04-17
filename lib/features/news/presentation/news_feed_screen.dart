import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../data/models/news_model.dart';
import '../data/repositories/news_repository.dart';
import 'widgets/news_card_widget.dart';
import 'widgets/news_skeleton_widget.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  final _repository = NewsRepository();

  NewsCategory _selectedCategory = NewsCategory.all;
  List<NewsItem> _news = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews({bool refresh = false}) async {
    if (!refresh) setState(() => _isLoading = true);
    setState(() => _errorMessage = null);

    try {
      final items = await _repository.fetchNews(
        category: _selectedCategory == NewsCategory.all
            ? null
            : _selectedCategory,
      );
      if (mounted) {
        setState(() {
          _news = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '뉴스를 불러올 수 없습니다.\n네트워크 연결을 확인해주세요.';
          _isLoading = false;
        });
      }
    }
  }

  void _onCategoryChanged(NewsCategory category) {
    if (_selectedCategory == category) return;
    setState(() => _selectedCategory = category);
    _loadNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.newsTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _CategoryFilterBar(
            selected: _selectedCategory,
            onChanged: _onCategoryChanged,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => _loadNews(refresh: true),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    // 로딩 중 — shimmer 스켈레톤
    if (_isLoading) {
      return const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: NewsSkeletonList(count: 6),
      );
    }

    // 오류
    if (_errorMessage != null) {
      return _ErrorView(
        message: _errorMessage!,
        onRetry: _loadNews,
      );
    }

    // 결과 없음
    if (_news.isEmpty) {
      return _EmptyView(category: _selectedCategory);
    }

    // 뉴스 목록
    return ListView.builder(
      itemCount: _news.length,
      itemBuilder: (context, index) => NewsCardWidget(news: _news[index]),
    );
  }
}

// ── 카테고리 필터 바 ──────────────────────────────────────
class _CategoryFilterBar extends StatelessWidget {
  final NewsCategory selected;
  final ValueChanged<NewsCategory> onChanged;

  const _CategoryFilterBar({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      color: AppColors.surface,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: NewsCategory.values.map((category) {
          final isSelected = selected == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                // WCAG 2.1 AA: 최소 48dp 터치 영역 (vertical 14dp × 2 + 16sp ≈ 48dp)
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.accent : AppColors.border,
                    width: 1.2,
                  ),
                ),
                child: Text(
                  category.label,
                  style: TextStyle(
                    fontSize: AppTypography.sizeSm,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── 오류 화면 ─────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined,
                size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppTypography.sizeMd,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 결과 없음 화면 ────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  final NewsCategory category;

  const _EmptyView({required this.category});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.newspaper_outlined,
              size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            "'${category.label}' 카테고리 뉴스가 없습니다",
            style: const TextStyle(
              fontSize: AppTypography.sizeMd,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
