// ══════════════════════════════════════════════════════════
// firebase_options.dart — FlutterFire CLI 자동 생성 파일
//
// ⚠️  이 파일의 TODO 값들을 채우는 방법 (2가지 중 선택):
//
// ★ 방법 1 — FlutterFire CLI (권장, 자동 생성)
//   1. Firebase Console에서 프로젝트 생성:
//      이름: kimtaesung-sinanjuso
//   2. 터미널에서:
//      dart pub global activate flutterfire_cli
//      flutterfire configure --project=kimtaesung-sinanjuso
//   3. 이 파일이 자동으로 실제 값으로 교체됩니다.
//
// ★ 방법 2 — 수동 입력
//   Firebase Console → 프로젝트 설정 → 내 앱 → google-services.json / GoogleService-Info.plist
//   에서 값을 확인하여 아래 TODO 항목에 직접 입력하세요.
//
// ── 설정 완료 전 앱은 오프라인 모드로 동작합니다 ───────────
// ══════════════════════════════════════════════════════════

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        '웹 플랫폼은 지원하지 않습니다. '
        'iOS/Android 전용 앱입니다.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          '지원하지 않는 플랫폼: $defaultTargetPlatform',
        );
    }
  }

  // ── Android (google-services.json → package_name: com.kimtaesung.sinanjuso) ─

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBCmxZEb2dMjI7o6fr8Wx-wR5tq7C_D4Rs',
    appId: '1:679589598320:android:fe1ec7694cc1b50b4750b5',
    messagingSenderId: '679589598320',
    projectId: 'kimtaesung-sinanjuso',
    storageBucket: 'kimtaesung-sinanjuso.firebasestorage.app',
  );

  // Firebase Console → 프로젝트 설정 → Android 앱 → google-services.json

  // ── iOS (GoogleService-Info.plist → BUNDLE_ID: com.kimtaesung.sinanjuso) ────

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBtap9g7oVTDT3Wj9rTARrW4AINCDigeNU',
    appId: '1:679589598320:ios:cf6dca4a13a2106a4750b5',
    messagingSenderId: '679589598320',
    projectId: 'kimtaesung-sinanjuso',
    storageBucket: 'kimtaesung-sinanjuso.firebasestorage.app',
    iosBundleId: 'com.kimtaesung.sinanjuso',
  );

  // Firebase Console → 프로젝트 설정 → iOS 앱 → GoogleService-Info.plist
}