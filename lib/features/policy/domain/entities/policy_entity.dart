import 'package:flutter/material.dart';

class RoadmapStep {
  final int step;
  final String title;
  final String subtitle;

  const RoadmapStep({
    required this.step,
    required this.title,
    required this.subtitle,
  });
}

class PolicyEntity {
  final String id;
  final String emoji;
  final String title;
  final String subtitle;
  final Color cardColor;
  final Color iconBgColor;
  final String background;   // 정책 배경 본문
  final String goals;        // 목표/기대효과
  final List<RoadmapStep> roadmap;
  final double averageRating;
  final int ratingCount;

  const PolicyEntity({
    required this.id,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.cardColor,
    required this.iconBgColor,
    required this.background,
    required this.goals,
    required this.roadmap,
    this.averageRating = 0.0,
    this.ratingCount = 0,
  });
}
