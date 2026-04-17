import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // 브랜드 메인 컬러
  static const Color primary = Color(0xFF1B3A6B);      // 딥 블루
  static const Color primaryMid = Color(0xFF2E6DB4);   // 미드 블루
  static const Color primaryLight = Color(0xFFD0E4F7); // 라이트 블루
  static const Color accent = Color(0xFFE8941A);       // 오렌지 액센트

  // 배경
  static const Color background = Color(0xFFF4F6FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFECEFF4);

  // 텍스트
  static const Color textPrimary = Color(0xFF222222);
  static const Color textSecondary = Color(0xFF555555);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // 테두리
  static const Color border = Color(0xFFDDE3EE);

  // 팩트체크 등급
  static const Color factGreen = Color(0xFF38A169);
  static const Color factYellow = Color(0xFFD69E2E);
  static const Color factRed = Color(0xFFE53E3E);

  // 정책 카드 배경
  static const Color cardBlue = Color(0xFFEBF4FF);
  static const Color cardYellow = Color(0xFFFFFCE8);
  static const Color cardPurple = Color(0xFFF0EEFF);
  static const Color cardGreen = Color(0xFFEDFBF0);
  static const Color cardOrange = Color(0xFFFFF5EA);
  static const Color cardPink = Color(0xFFFFF0F5);

  // 상태
  static const Color error = Color(0xFFE53E3E);
  static const Color success = Color(0xFF38A169);
  static const Color warning = Color(0xFFD69E2E);

  // 하단 네비게이션
  static const Color navSelected = primary;
  static const Color navUnselected = Color(0xFF9E9E9E);
}
