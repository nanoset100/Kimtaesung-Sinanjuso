import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  // 고령자 배려: 최소 16sp 기준
  static const double sizeXs = 12.0;
  static const double sizeSm = 14.0;
  static const double sizeMd = 16.0;   // 최소 기준
  static const double sizeLg = 18.0;
  static const double sizeXl = 22.0;
  static const double size2xl = 28.0;
  static const double size3xl = 36.0;

  static const TextStyle displayLarge = TextStyle(
    fontSize: size3xl,
    fontWeight: FontWeight.w900,
    height: 1.2,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: size2xl,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: sizeXl,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: sizeLg,
    fontWeight: FontWeight.w700,
    height: 1.5,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: sizeMd,
    fontWeight: FontWeight.w400,
    height: 1.7,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: sizeSm,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: sizeMd,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: sizeXs,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
}
