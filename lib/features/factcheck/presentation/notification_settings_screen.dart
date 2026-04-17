import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../data/factcheck_data.dart';
import 'widgets/countdown_widget.dart';
import 'widgets/factcheck_badge_widget.dart';

// ══════════════════════════════════════════════════════════
// 팩트체크 & 알림 설정 화면 — P2
//
// CLAUDE.md 앱스토어 정책 준수:
//   ✅ 투표 독려: 중립적 문구만 ("소중한 한 표를 행사해 주세요")
//   ✅ 팩트체크: GREEN/YELLOW/RED 등급, 특정인 공격 표현 금지
//   ✅ 출처 명시: 공신력 있는 공식 자료 링크
//   ✅ FCM: firebase_messaging 구독/해제만 (개인정보 미전송)
//   ✅ 로컬 알림: 기기 내 예약만, 서버 전송 없음
// ══════════════════════════════════════════════════════════
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen>
    with SingleTickerProviderStateMixin {
  static const String _hiveBox = 'notification_prefs';

  late TabController _tabController;

  // 토픽별 구독 상태 (Hive 영속화)
  final Map<NotificationTopic, bool> _subscriptions = {
    for (final t in NotificationTopic.values) t: true,
  };

  // 알림 내역 (실제 앱: FCM + Hive 저장)
  List<NotificationItem> _notifications =
      List.from(MockFactCheckData.recentNotifications);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPrefs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    if (!Hive.isBoxOpen(_hiveBox)) {
      await Hive.openBox<bool>(_hiveBox);
    }
    final box = Hive.box<bool>(_hiveBox);
    if (mounted) {
      setState(() {
        for (final t in NotificationTopic.values) {
          _subscriptions[t] = box.get(t.topicId, defaultValue: true)!;
        }
      });
    }
  }

  Future<void> _toggleTopic(NotificationTopic topic, bool value) async {
    if (!Hive.isBoxOpen(_hiveBox)) {
      await Hive.openBox<bool>(_hiveBox);
    }
    final box = Hive.box<bool>(_hiveBox);
    await box.put(topic.topicId, value);

    // ── Firebase Messaging 토픽 구독/해제 ─────────────────
    try {
      if (value) {
        await FirebaseMessaging.instance.subscribeToTopic(topic.topicId);
      } else {
        await FirebaseMessaging.instance.unsubscribeFromTopic(topic.topicId);
      }
    } catch (e) {
      // Firebase 미초기화 시 무시 (오프라인 모드에서도 토글 UI 동작)
      debugPrint('FCM 토픽 설정 실패: $e');
    }

    // ── D-Day 알림: 로컬 예약 (설정 완료 후 주석 해제) ────────
    // if (topic == NotificationTopic.dday) {
    //   if (value) {
    //     await _scheduleElectionDayNotification();
    //   } else {
    //     await flutterLocalNotificationsPlugin.cancel(999);
    //   }
    // }

    if (mounted) setState(() => _subscriptions[topic] = value);

    final msg = value ? '${topic.label} 구독 완료' : '${topic.label} 해제';
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // ── flutter_local_notifications 선거일 D-Day 예약 ─────────
  // (firebase + local notifications 설정 완료 후 활성화)
  // Future<void> _scheduleElectionDayNotification() async {
  //   final scheduledDate = tz.TZDateTime.from(
  //     MockFactCheckData.electionDate.subtract(const Duration(days: 1)),
  //     tz.local,
  //   ).copyWith(hour: 8, minute: 0, second: 0);
  //
  //   await flutterLocalNotificationsPlugin.zonedSchedule(
  //     999,
  //     '🗳️ 내일은 투표일입니다!',
  //     '2026년 6월 3일 — 소중한 한 표를 꼭 행사해 주세요.',
  //     scheduledDate,
  //     const NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         'election_dday', '선거일 알림',
  //         importance: Importance.max,
  //         priority: Priority.high,
  //       ),
  //       iOS: DarwinNotificationDetails(),
  //     ),
  //     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  //     uiLocalNotificationDateInterpretation:
  //         UILocalNotificationDateInterpretation.absoluteTime,
  //   );
  // }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _markAllRead() {
    setState(() {
      _notifications = _notifications
          .map((n) => NotificationItem(
                id: n.id,
                title: n.title,
                body: n.body,
                topic: n.topic,
                receivedAt: n.receivedAt,
                isRead: true,
              ))
          .toList();
    });
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('팩트체크 & 알림'),
        actions: [
          if (_unreadCount > 0 && _tabController.index == 2)
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                '모두 읽음',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: AppTypography.sizeSm,
                ),
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => setState(() {}), // actions 갱신
          tabs: [
            const Tab(icon: Icon(Icons.timer_outlined), text: 'D-Day'),
            const Tab(
                icon: Icon(Icons.fact_check_outlined), text: '팩트체크'),
            Tab(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.notifications_outlined),
                        SizedBox(width: 4),
                        Text('알림'),
                      ],
                    ),
                  ),
                  if (_unreadCount > 0)
                    Positioned(
                      right: 0,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$_unreadCount',
                          style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          indicatorColor: AppColors.accent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _DdayTab(),
          _FactCheckTab(onSourceTap: _openUrl),
          _NotificationTab(
            notifications: _notifications,
            subscriptions: _subscriptions,
            onToggle: _toggleTopic,
          ),
        ],
      ),
    );
  }
}

// ── D-Day 탭 ──────────────────────────────────────────────
class _DdayTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        // D-Day 카운트다운
        const CountdownWidget(),

        // 선거 정보 카드
        _InfoCard(
          icon: Icons.info_outline,
          title: '선거 정보',
          items: const [
            _InfoRow(label: '선거명', value: '제8회 전국동시지방선거'),
            _InfoRow(label: '선거일', value: '2026년 6월 3일 (수)'),
            _InfoRow(label: '선거구', value: '전라남도 신안군'),
            _InfoRow(label: '선거종류', value: '군수 선거'),
          ],
        ),

        // 투표 안내 카드
        _InfoCard(
          icon: Icons.how_to_vote_outlined,
          title: '투표 안내',
          items: const [
            _InfoRow(label: '사전투표', value: '2026년 5월 29일(금) ~ 30일(토)'),
            _InfoRow(label: '투표시간', value: '오전 6시 ~ 오후 6시'),
            _InfoRow(label: '투표소 확인', value: '중앙선거관리위원회 사이트'),
            _InfoRow(label: '지참물', value: '신분증 (주민등록증·여권 등)'),
          ],
        ),

        // 투표소 찾기 버튼
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: OutlinedButton.icon(
            onPressed: () async {
              final uri = Uri.parse('https://www.nec.go.kr');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri,
                    mode: LaunchMode.externalApplication);
              }
            },
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('중앙선관위 투표소 찾기'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              side: const BorderSide(color: AppColors.primary),
              foregroundColor: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

// ── 팩트체크 탭 ───────────────────────────────────────────
class _FactCheckTab extends StatelessWidget {
  final void Function(String url) onSourceTap;

  const _FactCheckTab({required this.onSourceTap});

  @override
  Widget build(BuildContext context) {
    final items = MockFactCheckData.items;

    // 등급별 집계
    final greenCount =
        items.where((i) => i.rating == FactRating.green).length;
    final yellowCount =
        items.where((i) => i.rating == FactRating.yellow).length;
    final redCount = items.where((i) => i.rating == FactRating.red).length;

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        // 등급 요약 바
        Container(
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: _RatingSummaryItem(
                  rating: FactRating.green,
                  count: greenCount,
                ),
              ),
              const SizedBox(
                  height: 40,
                  child: VerticalDivider(color: AppColors.border)),
              Expanded(
                child: _RatingSummaryItem(
                  rating: FactRating.yellow,
                  count: yellowCount,
                ),
              ),
              const SizedBox(
                  height: 40,
                  child: VerticalDivider(color: AppColors.border)),
              Expanded(
                child: _RatingSummaryItem(
                  rating: FactRating.red,
                  count: redCount,
                ),
              ),
            ],
          ),
        ),

        // 팩트체크 카드 목록
        ...items.map(
          (item) => FactCheckCard(
            item: item,
            onSourceTap: () => onSourceTap(item.sourceUrl),
          ),
        ),

        // 하단 안내
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline,
                    size: 14, color: AppColors.primary),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '팩트체크는 공신력 있는 공개 자료를 기반으로 작성됩니다. '
                    '추가 검증이 필요한 사항은 출처 링크를 통해 직접 확인해 주세요.',
                    style: TextStyle(
                      fontSize: AppTypography.sizeXs,
                      color: AppColors.primary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── 알림 탭 ───────────────────────────────────────────────
class _NotificationTab extends StatelessWidget {
  final List<NotificationItem> notifications;
  final Map<NotificationTopic, bool> subscriptions;
  final Future<void> Function(NotificationTopic, bool) onToggle;

  const _NotificationTab({
    required this.notifications,
    required this.subscriptions,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        // ── 알림 수신 설정 ───────────────────────────────
        _SectionHeader(title: '🔔 알림 수신 설정'),
        Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(
            children: NotificationTopic.values.map((topic) {
              final isLast =
                  topic == NotificationTopic.values.last;
              return Column(
                children: [
                  _TopicToggleTile(
                    topic: topic,
                    value: subscriptions[topic] ?? true,
                    onChanged: (v) => onToggle(topic, v),
                  ),
                  if (!isLast)
                    const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: AppColors.border),
                ],
              );
            }).toList(),
          ),
        ),

        // ── 최근 알림 내역 ───────────────────────────────
        _SectionHeader(title: '📨 최근 알림 내역'),
        if (notifications.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(Icons.notifications_none,
                    size: 48, color: AppColors.border),
                SizedBox(height: 8),
                Text(
                  '아직 받은 알림이 없습니다',
                  style: TextStyle(
                    fontSize: AppTypography.sizeSm,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          ...notifications.map(
            (item) => _NotificationTile(item: item),
          ),
      ],
    );
  }
}

// ── 알림 토픽 토글 타일 ───────────────────────────────────
class _TopicToggleTile extends StatelessWidget {
  final NotificationTopic topic;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _TopicToggleTile({
    required this.topic,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      secondary: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: value ? AppColors.primaryLight : AppColors.border.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          topic.icon,
          size: 20,
          color: value ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
      title: Text(
        topic.label,
        style: TextStyle(
          fontSize: AppTypography.sizeMd,
          fontWeight: FontWeight.w600,
          color: value ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
      subtitle: Text(
        topic.subtitle,
        style: const TextStyle(
          fontSize: AppTypography.sizeXs,
          color: AppColors.textSecondary,
          height: 1.4,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }
}

// ── 알림 내역 타일 ────────────────────────────────────────
class _NotificationTile extends StatelessWidget {
  final NotificationItem item;

  const _NotificationTile({required this.item});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays >= 1) return '${diff.inDays}일 전';
    if (diff.inHours >= 1) return '${diff.inHours}시간 전';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}분 전';
    return '방금 전';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      decoration: BoxDecoration(
        color: item.isRead
            ? AppColors.surface
            : AppColors.primaryLight.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.isRead ? AppColors.border : AppColors.primary.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: item.isRead
                ? AppColors.border.withValues(alpha: 0.4)
                : AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            item.topic.icon,
            size: 20,
            color: item.isRead
                ? AppColors.textSecondary
                : AppColors.primary,
          ),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontSize: AppTypography.sizeSm,
            fontWeight:
                item.isRead ? FontWeight.w400 : FontWeight.w700,
            color: item.isRead
                ? AppColors.textSecondary
                : AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              item.body,
              style: const TextStyle(
                fontSize: AppTypography.sizeXs,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _timeAgo(item.receivedAt),
              style: const TextStyle(
                fontSize: AppTypography.sizeXs,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        trailing: !item.isRead
            ? Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              )
            : null,
      ),
    );
  }
}

// ── 보조 위젯들 ───────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: AppTypography.sizeMd,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<_InfoRow> items;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.items,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: AppTypography.sizeMd,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.primaryLight),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: items,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: AppTypography.sizeSm,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: AppTypography.sizeSm,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingSummaryItem extends StatelessWidget {
  final FactRating rating;
  final int count;

  const _RatingSummaryItem({required this.rating, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(rating.icon, color: rating.color, size: 22),
        const SizedBox(height: 4),
        Text(
          '$count건',
          style: TextStyle(
            fontSize: AppTypography.sizeMd,
            fontWeight: FontWeight.w700,
            color: rating.color,
          ),
        ),
        Text(
          rating.label,
          style: TextStyle(
            fontSize: AppTypography.sizeXs,
            color: rating.color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
