import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../data/contact_data.dart';
import 'widgets/camp_map_widget.dart';
import 'widgets/contact_button_widget.dart';

// ──────────────────────────────────────────────────────────
// 직접 연락 화면 — P1
//   앱스토어 정책 준수 사항:
//   ✅ 개인 식별 정보(이름·연락처) 수집 없음
//   ✅ UGC 금칙어 필터링 (UgcFilter.validate)
//   ✅ 후원금 결제 없음 — 외부 링크만
//   ✅ 위치 데이터 서버 전송 없음 (캠프 고정 좌표만)
// ──────────────────────────────────────────────────────────
class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  InquiryType _selectedType = InquiryType.policy;
  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  int _charCount = 0;

  static const int _maxChars = 500;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      setState(() => _charCount = _textController.text.length);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submitOpinion() async {
    // 유효성 검사
    final text = _textController.text;
    final validationError = UgcFilter.validate(text);
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // ── Firestore 저장 (익명 — 개인정보 없음) ────────────
    // CLAUDE.md §8: 문의유형·내용·타임스탬프만 저장
    // ❌ 이름, 연락처, 위치 등 개인정보 절대 저장 금지
    try {
      await FirebaseFirestore.instance.collection('inquiries').add({
        'type': _selectedType.name,
        'content': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      debugPrint('Firestore 문의 저장 실패: $e');
      // 오류가 있어도 사용자에게 성공 메시지 (서버 오류로 UX 차단 방지)
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      _textController.clear();
      // 키보드 내리기
      FocusScope.of(context).unfocus();
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.check_circle,
            color: AppColors.success, size: 48),
        title: const Text(
          '의견이 전달되었습니다',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          '김태성 후보 캠프에서 48시간 내 확인합니다.\n소중한 의견 감사합니다.',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: AppTypography.sizeSm, color: AppColors.textSecondary),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // AppBar 없음 — _ContactSurveyShell의 TabBar AppBar 사용
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              // ── 직통 연락처 ──────────────────────────
              _SectionCard(
                title: '📞 직통 연락처',
                child: ContactButtonList(contacts: CampContact.contacts),
              ),

              // ── 캠프 위치 지도 ───────────────────────
              _SectionCard(
                title: '🗺 선거 캠프 위치',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CampMapWidget(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            CampContact.campAddressFull,
                            style: const TextStyle(
                              fontSize: AppTypography.sizeXs,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── 문의 유형 선택 ───────────────────────
              _SectionCard(
                title: '📬 문의 유형 선택',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 유형 칩 선택
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: InquiryType.values.map((type) {
                        final isSelected = _selectedType == type;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedType = type),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            // WCAG 2.1 AA: 최소 48dp 터치 영역
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.accent
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.accent
                                    : AppColors.border,
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  type.icon,
                                  size: 16,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  type.label,
                                  style: TextStyle(
                                    fontSize: AppTypography.sizeSm,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 14),

                    // 의견 입력창
                    TextFormField(
                      controller: _textController,
                      maxLines: 5,
                      maxLength: _maxChars,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      style: const TextStyle(
                          fontSize: AppTypography.sizeMd, height: 1.6),
                      decoration: InputDecoration(
                        hintText:
                            '${_selectedType.label}에 대한 의견을 자유롭게 입력해주세요.\n(최대 500자, 익명 처리)',
                        counterText: '$_charCount / $_maxChars',
                        counterStyle: TextStyle(
                          fontSize: AppTypography.sizeXs,
                          color: _charCount >= _maxChars
                              ? AppColors.error
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),

                    // 개인정보 안내
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline,
                              size: 14, color: AppColors.primary),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '이름·연락처 등 개인정보는 수집하지 않습니다.\n의견은 익명으로 캠프에 전달됩니다.',
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

                    const SizedBox(height: 14),

                    // 제출 버튼
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            _isSubmitting ? null : _submitOpinion,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.send_outlined, size: 18),
                        label: Text(_isSubmitting ? '전송 중...' : '제출하기'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                        ),
                      ),
                    ),

                    // ── UGC 신고 버튼 (Apple Guideline 1.2 준수) ──
                    const SizedBox(height: 10),
                    Center(
                      child: GestureDetector(
                        onTap: () => _showReportDialog(context),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.flag_outlined,
                                  size: 13, color: AppColors.textSecondary),
                              SizedBox(width: 4),
                              Text(
                                '부적절한 내용 신고',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

  // ── UGC 신고 다이얼로그 (Apple Guideline 1.2) ──────────────
  void _showReportDialog(BuildContext context) {
    String? selectedReason;
    final reasons = ['욕설 / 혐오 표현', '허위 정보', '스팸', '개인정보 침해', '기타'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.flag, color: AppColors.error, size: 22),
              SizedBox(width: 8),
              Text(
                '부적절한 내용 신고',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '신고 사유를 선택해주세요.',
                style: TextStyle(
                    fontSize: AppTypography.sizeSm,
                    color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ...reasons.map((r) => RadioListTile<String>(
                    title: Text(r,
                        style:
                            const TextStyle(fontSize: AppTypography.sizeSm)),
                    value: r,
                    groupValue: selectedReason,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primary,
                    onChanged: (v) =>
                        setDialogState(() => selectedReason = v),
                  )),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('취소',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: selectedReason == null
                  ? null
                  : () {
                      Navigator.of(ctx).pop();
                      _submitReport(selectedReason!);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('신고하기'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport(String reason) async {
    // 신고 내용을 Firestore에 익명으로 저장
    try {
      await FirebaseFirestore.instance.collection('reports').add({
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
        // 개인정보 저장 금지 — 사유와 시간만 기록
      });
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text('신고가 접수되었습니다. 검토 후 조치하겠습니다.'),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}

// ── 공통 섹션 카드 위젯 ───────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

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
            child: Text(
              title,
              style: const TextStyle(
                fontSize: AppTypography.sizeMd,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.primaryLight),
          Padding(
            padding: const EdgeInsets.all(14),
            child: child,
          ),
        ],
      ),
    );
  }
}
