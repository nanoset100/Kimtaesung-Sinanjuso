import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/survey_model.dart';

// ══════════════════════════════════════════════════════════
// 설문 저장소 — CLAUDE.md §8 보안 규칙 완전 준수
//
// Firestore 컬렉션 구조:
//   survey_votes/{anonymousId}
//     - surveyId, questionId, optionId, timestamp
//     - read: false (개별 투표 열람 금지)
//     - create: 특정 필드만 허용, 이미 존재하면 거부
//
//   survey_aggregates/{surveyId_questionId}
//     - optionId별 count (Cloud Functions가 집계)
//     - read: true (결과 표시용)
//     - write: false (앱에서 직접 수정 불가)
//
// 익명성 보장:
//   anonymousId = sha256(deviceKey + surveyId + questionId)
//   → deviceKey는 기기 내 Hive에만 존재, 서버 미전송
//   → 같은 기기·설문·문항 조합은 항상 같은 ID → 중복 차단
// ══════════════════════════════════════════════════════════
class SurveyRepository {
  static final SurveyRepository _instance = SurveyRepository._internal();
  factory SurveyRepository() => _instance;
  SurveyRepository._internal();

  static const String _hiveBox = 'survey_prefs';
  static const String _deviceKeyField = 'device_key';

  // ── 기기 고유 키 (익명 해시용) ─────────────────────────
  Future<String> _getDeviceKey() async {
    if (!Hive.isBoxOpen(_hiveBox)) {
      await Hive.openBox<String>(_hiveBox);
    }
    final box = Hive.box<String>(_hiveBox);
    var key = box.get(_deviceKeyField);
    if (key == null) {
      key = DateTime.now().microsecondsSinceEpoch.toRadixString(16) +
          DateTime.now().millisecond.toRadixString(16);
      await box.put(_deviceKeyField, key);
    }
    return key;
  }

  // ── 익명 ID 생성 ────────────────────────────────────────
  // sha256(deviceKey + surveyId + questionId) — 완전 익명, 역추적 불가
  Future<String> _buildAnonymousId(
      String surveyId, String questionId) async {
    final deviceKey = await _getDeviceKey();
    final raw = utf8.encode('$deviceKey$surveyId$questionId');
    return sha256.convert(raw).toString();
  }

  // ── 이미 투표했는지 확인 (로컬 Hive 우선) ───────────────
  Future<bool> hasVoted(String surveyId, String questionId) async {
    if (!Hive.isBoxOpen(_hiveBox)) {
      await Hive.openBox<String>(_hiveBox);
    }
    final box = Hive.box<String>(_hiveBox);
    return box.containsKey('voted_${surveyId}_$questionId');
  }

  // ── 투표 제출 ───────────────────────────────────────────
  Future<void> submitVote({
    required String surveyId,
    required String questionId,
    required String optionId,
  }) async {
    final anonymousId = await _buildAnonymousId(surveyId, questionId);

    // ── Firestore 저장 (익명 — 개인정보 없음) ────────────
    // CLAUDE.md §8:
    //   allow create: if request.resource.data.keys()
    //     .hasOnly(['surveyId','questionId','optionId','timestamp']);
    try {
      await FirebaseFirestore.instance
          .collection('survey_votes')
          .doc(anonymousId) // 익명 ID가 문서 ID → 중복 투표 자동 차단
          .set(
        {
          'surveyId': surveyId,
          'questionId': questionId,
          'optionId': optionId,
          'timestamp': FieldValue.serverTimestamp(),
          // ❌ 절대 포함 금지: name, phone, email, location
        },
        // merge: false 동작 = 동일 문서 존재 시 Firestore 보안규칙이 거부
        SetOptions(merge: false),
      );
    } on FirebaseException catch (e) {
      // permission-denied = 이미 투표한 기기 → 정상 흐름, 무시
      if (e.code != 'permission-denied') rethrow;
    }

    // 로컬 Hive에 투표 완료 기록 (오프라인/복원용)
    if (!Hive.isBoxOpen(_hiveBox)) {
      await Hive.openBox<String>(_hiveBox);
    }
    final box = Hive.box<String>(_hiveBox);
    await box.put('voted_${surveyId}_$questionId', optionId);

    // 로컬 스트림 집계도 갱신 (Firestore 스트림 보조)
    _updateLocalAggregate(surveyId, questionId, optionId);
  }

  // ── 기존 선택값 가져오기 ────────────────────────────────
  Future<String?> getPreviousVote(
      String surveyId, String questionId) async {
    if (!Hive.isBoxOpen(_hiveBox)) {
      await Hive.openBox<String>(_hiveBox);
    }
    final box = Hive.box<String>(_hiveBox);
    return box.get('voted_${surveyId}_$questionId');
  }

  // ── 실시간 집계 스트림 (Firestore → 로컬 폴백) ──────────
  // Firestore survey_aggregates는 Cloud Functions가 집계하여 기록
  // 앱은 읽기 전용으로 구독
  Stream<SurveyAggregate> watchAggregate(
      String surveyId, String questionId) {
    return FirebaseFirestore.instance
        .collection('survey_aggregates')
        .doc('${surveyId}_$questionId')
        .snapshots()
        .map((snap) {
          if (snap.exists && snap.data() != null) {
            return SurveyAggregate.fromMap(surveyId, questionId, snap.data()!);
          }
          // Firestore 문서 없음 → 로컬 목업 집계 반환
          return _localAggregates['${surveyId}_$questionId'] ??
              MockSurveyData.mockAggregate(questionId);
        })
        .handleError((_) {
          // Firestore 오류 시 로컬 StreamController로 폴백
          return _localAggregates['${surveyId}_$questionId'] ??
              MockSurveyData.mockAggregate(questionId);
        });
  }

  // ── 집계 초기값 즉시 읽기 (StreamBuilder 초기 데이터) ───
  SurveyAggregate getAggregateSync(String surveyId, String questionId) {
    final key = '${surveyId}_$questionId';
    return _localAggregates[key] ?? MockSurveyData.mockAggregate(questionId);
  }

  // ── 로컬 집계 (Firestore 연결 전 즉각 반응용) ────────────
  final Map<String, SurveyAggregate> _localAggregates = {};

  void _updateLocalAggregate(
      String surveyId, String questionId, String optionId) {
    final key = '${surveyId}_$questionId';
    final prev = _localAggregates[key] ?? MockSurveyData.mockAggregate(questionId);
    final newCounts = Map<String, int>.from(prev.counts);
    newCounts[optionId] = (newCounts[optionId] ?? 0) + 1;
    _localAggregates[key] = SurveyAggregate(
      surveyId: surveyId,
      questionId: questionId,
      counts: newCounts,
      total: prev.total + 1,
    );
  }
}
