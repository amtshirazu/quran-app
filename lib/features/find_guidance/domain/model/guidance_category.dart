import 'package:flutter/material.dart';

class GuidanceCategory {
  final String emotion;
  final int verseCount;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const GuidanceCategory({
    required this.emotion,
    required this.verseCount,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });
}
