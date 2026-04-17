import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/contact/presentation/contact_screen.dart';
import 'features/factcheck/presentation/notification_settings_screen.dart';
import 'features/survey/presentation/survey_screen.dart';
import 'features/news/presentation/news_feed_screen.dart';
import 'features/policy/presentation/policy_list_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'shared/widgets/bottom_nav_bar.dart';
import 'shared/widgets/candidate_popup.dart';

// 소통 탭: 직접연락 + 설문투표 탭바 쉘
class _ContactSurveyShell extends StatelessWidget {
  const _ContactSurveyShell();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('소통'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.phone_outlined), text: '직접 연락'),
              Tab(icon: Icon(Icons.how_to_vote_outlined), text: '설문 투표'),
            ],
            indicatorColor: AppColors.accent,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: const TabBarView(
          children: [
            ContactScreen(),
            SurveyScreen(),
          ],
        ),
      ),
    );
  }
}

class SinanjusoApp extends StatelessWidget {
  const SinanjusoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 1; // 첫 화면: 정책 탭
  static bool _popupShown = false; // 앱 세션당 1회만 표시

  @override
  void initState() {
    super.initState();
    if (!_popupShown) {
      _popupShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showRandomCandidatePopup(context);
      });
    }
  }

  static const List<Widget> _screens = [
    ProfileScreen(),
    PolicyListScreen(),
    NewsFeedScreen(),
    _ContactSurveyShell(),  // 소통 탭 — 연락 / 설문 탭바
    NotificationSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
