import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/factcheck_data.dart';

// ── D-Day 카운트다운 위젯 ─────────────────────────────────
// 선거일: 2026년 6월 3일 (제8회 전국동시지방선거)
// 매 초마다 자동 갱신
class CountdownWidget extends StatefulWidget {
  const CountdownWidget({super.key});

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = _calcRemaining();
    // 1초마다 갱신
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _remaining = _calcRemaining());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Duration _calcRemaining() {
    final now = DateTime.now();
    final election = MockFactCheckData.electionDate;
    // 선거일 당일 자정 기준
    final target = DateTime(election.year, election.month, election.day);
    final diff = target.difference(DateTime(now.year, now.month, now.day));
    return diff.isNegative ? Duration.zero : diff;
  }

  @override
  Widget build(BuildContext context) {
    final days = _remaining.inDays;
    final isElectionDay = days == 0;
    final isPast = MockFactCheckData.electionDate
        .isBefore(DateTime.now().subtract(const Duration(days: 1)));

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isElectionDay
              ? [const Color(0xFFE8941A), const Color(0xFFFF6F00)]
              : [AppColors.primary, AppColors.primaryMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          children: [
            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.how_to_vote_outlined,
                    color: Colors.white70, size: 18),
                const SizedBox(width: 6),
                Text(
                  isPast ? '선거가 종료되었습니다' : '제8회 전국동시지방선거',
                  style: const TextStyle(
                    fontSize: AppTypography.sizeSm,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '2026년 6월 3일 (수)',
              style: const TextStyle(
                fontSize: AppTypography.sizeXs,
                color: Colors.white54,
              ),
            ),

            const SizedBox(height: 16),

            // D-Day 숫자
            if (isPast)
              const Text(
                '선거 완료',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              )
            else if (isElectionDay)
              const Text(
                'D-DAY  🗳️',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'D-',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    '$days',
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 12),

            // 투표 독려 문구 (중립적 — 선거법·앱스토어 정책 준수)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isElectionDay
                    ? '오늘은 투표일입니다. 소중한 한 표를 행사해 주세요!'
                    : isPast
                        ? '관심 가져주셔서 감사합니다.'
                        : '투표는 민주주의의 가장 중요한 참여입니다 🗳️',
                style: const TextStyle(
                  fontSize: AppTypography.sizeSm,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
