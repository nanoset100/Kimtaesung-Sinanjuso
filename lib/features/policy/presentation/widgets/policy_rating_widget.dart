import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

// ──────────────────────────────────────────────────────────
// 정책 별점 평가 위젯
// CLAUDE.md 앱스토어 정책 준수:
//   ✅ 개인 식별 정보 수집 금지
//   ✅ 익명 ID = sha256(localDeviceKey + policyId) — 역추적 불가
//   ✅ Firestore 저장 필드: policyId, rating, timestamp 만
//   ✅ Firestore 보안 규칙으로 이미 존재하는 문서 재쓰기 시도 차단
// ──────────────────────────────────────────────────────────
class PolicyRatingWidget extends StatefulWidget {
  final String policyId;

  const PolicyRatingWidget({super.key, required this.policyId});

  @override
  State<PolicyRatingWidget> createState() => _PolicyRatingWidgetState();
}

class _PolicyRatingWidgetState extends State<PolicyRatingWidget> {
  int _selectedRating = 0;
  bool _submitted = false;
  bool _isLoading = false;

  static const String _boxName = 'app_prefs';
  static const String _deviceKeyName = 'device_key';

  // 기기 고유 키 — Hive에만 저장, 서버 전송 없음
  Future<String> _getDeviceKey() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<String>(_boxName);
    }
    final box = Hive.box<String>(_boxName);
    var key = box.get(_deviceKeyName);
    if (key == null) {
      key = _generateUuid();
      await box.put(_deviceKeyName, key);
    }
    return key;
  }

  String _generateUuid() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final rng = now ^ (now >> 16);
    return rng.toRadixString(16).padLeft(16, '0');
  }

  // sha256(deviceKey + policyId) → 익명 문서 ID (역추적 불가)
  String _buildAnonymousId(String deviceKey) {
    final raw = utf8.encode('$deviceKey${widget.policyId}');
    return sha256.convert(raw).toString();
  }

  Future<void> _submitRating() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('별점을 선택해주세요')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final deviceKey = await _getDeviceKey();
      final anonymousId = _buildAnonymousId(deviceKey);

      // ── Firestore 저장 (익명 — 개인정보 없음) ────────────
      // CLAUDE.md §8 보안 규칙:
      //   survey_results/{id}: create만 허용, policyId·rating·timestamp 필드만
      await FirebaseFirestore.instance
          .collection('survey_results')
          .doc(anonymousId) // 익명 ID가 문서 ID → 중복 제출 차단
          .set({
        'policyId': widget.policyId,
        'rating': _selectedRating,
        'timestamp': FieldValue.serverTimestamp(),
        // ❌ 절대 포함 금지: name, phone, email, location
      });

      // 로컬 Hive에도 기록 (오프라인 복원용)
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox<String>(_boxName);
      }
      final box = Hive.box<String>(_boxName);
      await box.put('rated_${widget.policyId}', _selectedRating.toString());

      if (mounted) {
        setState(() {
          _submitted = true;
          _isLoading = false;
        });
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final msg = e.code == 'permission-denied'
            ? '이미 평가하셨습니다.'
            : '제출 중 오류가 발생했습니다. 다시 시도해주세요.';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('제출 중 오류가 발생했습니다. 다시 시도해주세요.')),
        );
      }
    }
  }

  Future<void> _checkPreviousRating() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<String>(_boxName);
    }
    final box = Hive.box<String>(_boxName);
    final prev = box.get('rated_${widget.policyId}');
    if (prev != null && mounted) {
      setState(() {
        _selectedRating = int.tryParse(prev) ?? 0;
        _submitted = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkPreviousRating();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 별 5개 (한 줄) ────────────────────────────────
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (i) {
            final filled = i < _selectedRating;
            return GestureDetector(
              onTap: _submitted
                  ? null
                  : () => setState(() => _selectedRating = i + 1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  filled ? Icons.star : Icons.star_border,
                  color: const Color(0xFFFFC107),
                  size: 32,
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 10),

        // ── 제출 버튼 / 완료 배지 (별도 줄) ─────────────
        if (!_submitted)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitRating,
              style: ElevatedButton.styleFrom(
                alignment: Alignment.center,
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('평가 제출'),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.success),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 16),
                SizedBox(width: 6),
                Text(
                  '제출 완료',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: AppTypography.sizeSm,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 8),
        const Text(
          '※ 익명으로 수집됩니다 — 개인정보는 저장되지 않습니다',
          style: TextStyle(
            fontSize: AppTypography.sizeXs,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
