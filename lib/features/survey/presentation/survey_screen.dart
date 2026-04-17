import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../data/models/survey_model.dart';
import '../data/repositories/survey_repository.dart';
import 'widgets/survey_question_card.dart';
import 'widgets/vote_chart_widget.dart';

// ══════════════════════════════════════════════════════════
// 설문 및 투표 화면 — P2
//
// CLAUDE.md 앱스토어 정책 준수:
//   ✅ 익명 참여: sha256(deviceKey + surveyId + questionId)
//   ✅ 개인정보 수집 없음 (이름·연락처·위치 저장 금지)
//   ✅ Firestore 중복 방지: 익명 ID가 문서 ID → 1기기 1투표
//   ✅ 결과 읽기: survey_aggregates (집계본만, 개별 표 열람 불가)
// ══════════════════════════════════════════════════════════
class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final _repo = SurveyRepository();

  // 문항별 선택값 & 제출 상태
  final Map<String, String?> _selections = {};   // questionId → optionId
  final Map<String, bool> _submitted = {};        // questionId → 제출여부
  bool _isSubmitting = false;

  // 전체 제출 가능 여부
  bool get _canSubmitAll {
    final questions = MockSurveyData.questions;
    return questions.every((q) =>
        _selections[q.id] != null && !(_submitted[q.id] ?? false));
  }

  @override
  void initState() {
    super.initState();
    _loadPreviousVotes();
  }

  Future<void> _loadPreviousVotes() async {
    for (final q in MockSurveyData.questions) {
      final prev = await _repo.getPreviousVote(q.surveyId, q.id);
      if (prev != null && mounted) {
        setState(() {
          _selections[q.id] = prev;
          _submitted[q.id] = true;
        });
      }
    }
  }

  Future<void> _submitAll() async {
    final unselected = MockSurveyData.questions
        .where((q) => _selections[q.id] == null && !(_submitted[q.id] ?? false))
        .toList();

    if (unselected.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('모든 문항에 답변해주세요'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      for (final q in MockSurveyData.questions) {
        final optionId = _selections[q.id];
        if (optionId != null && !(_submitted[q.id] ?? false)) {
          await _repo.submitVote(
            surveyId: q.surveyId,
            questionId: q.id,
            optionId: optionId,
          );
          if (mounted) setState(() => _submitted[q.id] = true);
        }
      }

      if (mounted) {
        setState(() => _isSubmitting = false);
        _showSuccessSnackBar();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('제출 중 오류가 발생했습니다. 다시 시도해주세요.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('의견이 후보에게 전달되었습니다. 감사합니다!'),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  bool get _allSubmitted =>
      MockSurveyData.questions.every((q) => _submitted[q.id] ?? false);

  @override
  Widget build(BuildContext context) {
    // AppBar 없음 — _ContactSurveyShell의 TabBar AppBar 사용
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          // 안내 배너
          _InfoBanner(allSubmitted: _allSubmitted),

          // 문항별 카드 + StreamBuilder 차트
          ...MockSurveyData.questions.map(
            (q) => _SurveyQuestionSection(
              question: q,
              selectedOptionId: _selections[q.id],
              isSubmitted: _submitted[q.id] ?? false,
              repo: _repo,
              onOptionSelected: (optionId) {
                if (!(_submitted[q.id] ?? false)) {
                  setState(() => _selections[q.id] = optionId);
                }
              },
            ),
          ),
        ],
      ),

      // 전체 제출 버튼 (하단 고정)
      bottomNavigationBar: _allSubmitted ? null : _SubmitBar(
        canSubmit: _canSubmitAll,
        isSubmitting: _isSubmitting,
        onSubmit: _submitAll,
      ),
    );
  }
}

// ── 문항 + 차트 복합 섹션 ────────────────────────────────
class _SurveyQuestionSection extends StatelessWidget {
  final SurveyQuestion question;
  final String? selectedOptionId;
  final bool isSubmitted;
  final SurveyRepository repo;
  final ValueChanged<String> onOptionSelected;

  const _SurveyQuestionSection({
    required this.question,
    required this.selectedOptionId,
    required this.isSubmitted,
    required this.repo,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 설문 문항 카드
        SurveyQuestionCard(
          question: question,
          selectedOptionId: selectedOptionId,
          isSubmitted: isSubmitted,
          onOptionSelected: onOptionSelected,
        ),

        // 결과 차트 (제출 완료 또는 이미 참여한 경우 표시)
        if (isSubmitted)
          _ResultChartCard(
            question: question,
            highlightOptionId: selectedOptionId,
            repo: repo,
          ),
      ],
    );
  }
}

// ── StreamBuilder 실시간 결과 차트 카드 ────────────────────
class _ResultChartCard extends StatelessWidget {
  final SurveyQuestion question;
  final String? highlightOptionId;
  final SurveyRepository repo;

  const _ResultChartCard({
    required this.question,
    required this.highlightOptionId,
    required this.repo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.all(16),
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
          // 헤더
          Row(
            children: [
              const Icon(Icons.bar_chart, color: AppColors.primaryMid, size: 18),
              const SizedBox(width: 6),
              const Text(
                '📊 실시간 집계 결과',
                style: TextStyle(
                  fontSize: AppTypography.sizeMd,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const Divider(height: 16, color: AppColors.border),

          // StreamBuilder — Firestore 연동 시 실시간 갱신
          StreamBuilder<SurveyAggregate>(
            // 초기값을 즉시 제공 (빈 화면 방지)
            initialData: repo.getAggregateSync(question.surveyId, question.id),
            stream: repo.watchAggregate(question.surveyId, question.id),
            builder: (context, snapshot) {
              final aggregate = snapshot.data ??
                  SurveyAggregate.empty(question.surveyId, question.id);

              return VoteChartWidget(
                question: question,
                aggregate: aggregate,
                highlightOptionId: highlightOptionId,
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── 안내 배너 ─────────────────────────────────────────────
class _InfoBanner extends StatelessWidget {
  final bool allSubmitted;

  const _InfoBanner({required this.allSubmitted});

  @override
  Widget build(BuildContext context) {
    if (allSubmitted) {
      return Container(
        margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                '이미 참여하셨습니다. 아래에서 실시간 결과를 확인하세요.',
                style: TextStyle(
                  fontSize: AppTypography.sizeSm,
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        '군민 여러분의 소중한 의견을 들려주세요.\n모든 응답은 익명으로 처리되며 개인정보는 수집하지 않습니다.',
        style: TextStyle(
          fontSize: AppTypography.sizeSm,
          color: AppColors.primary,
          height: 1.5,
        ),
      ),
    );
  }
}

// ── 하단 전체 제출 버튼 바 ────────────────────────────────
class _SubmitBar extends StatelessWidget {
  final bool canSubmit;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const _SubmitBar({
    required this.canSubmit,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: (canSubmit && !isSubmitting) ? onSubmit : null,
          icon: isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.send_outlined, size: 18),
          label: Text(
            isSubmitting ? '제출 중...' : '✅ 의견 제출 & 후보에게 전달',
            style: const TextStyle(
              fontSize: AppTypography.sizeMd,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            disabledBackgroundColor: AppColors.border,
          ),
        ),
      ),
    );
  }
}
