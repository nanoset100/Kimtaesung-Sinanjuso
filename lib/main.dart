import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'firebase_options.dart';

// ──────────────────────────────────────────────────────────
// 앱 진입점
//
// Firebase 초기화 순서:
//   1. lib/firebase_options.dart의 TODO 값들을 채울 것
//      (FlutterFire CLI: flutterfire configure --project=kimtaesung-sinanjuso)
//   2. android/app/google-services.json 배치
//   3. ios/Runner/GoogleService-Info.plist 배치
//   4. android/app/build.gradle에 google-services 플러그인 확인
//   5. ios/Runner/AppDelegate.swift에 FirebaseApp.configure() 확인
//
// ⚠️ firebase_options.dart의 TODO 값이 채워지기 전에는
//    Firebase 초기화에 실패하지만 앱은 오프라인 모드로 계속 동작합니다.
// ──────────────────────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 초기화 (로컬 캐시 — 오프라인 설문·별점·알림 설정)
  await Hive.initFlutter();

  await _initFirebase();

  runApp(const SinanjusoApp());
}

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase 초기화 성공');
  } catch (e) {
    // firebase_options.dart의 TODO 값이 채워지지 않았거나
    // google-services.json / GoogleService-Info.plist 미배치 시 발생
    // → 앱은 오프라인 모드(로컬 Hive 캐시)로 계속 동작
    debugPrint('⚠️  Firebase 초기화 실패 (오프라인 모드로 동작): $e');
    debugPrint('   → firebase_options.dart의 TODO 값을 채운 후 재빌드하세요.');
  }
}
