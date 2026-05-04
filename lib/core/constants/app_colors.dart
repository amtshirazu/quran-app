import 'package:flutter/material.dart';

class AppColors {
  // Emerald
  static const emerald50 = Color(0xFFECFDF5);
  static const emerald100 = Color(0xFFD1FAE5);
  static const emerald500 = Color(0xFF10B981);
  static const emerald600 = Color(0xFF059669);
  static const emerald200 = Color(0xFFA7F3D0);
  static const emerald300 = Color(0xFF6EE7B7);

  // Gray
  static const gray900 = Color(0xFF111827);
  static const gray700 = Color(0xFF374151);
  static const gray600 = Color(0xFF4B5563);
  static const gray500 = Color(0xFF6B7280);
  static const gray400 = Color(0xFF9CA3AF);
  static const gray300 = Color(0xFFD1D5DB);
  static const gray200 = Color(0xFFE5E7EB);
  static const gray100 = Color(0xFFF3F4F6);

  // Blue
  static const blue100 = Color(0xFFDBEAFE);
  static const blue500 = Color(0xFF3B82F6);
  static const blue600 = Color(0xFF2563EB);

  // Purple
  static const purple100 = Color(0xFFEDE9FE);
  static const purple500 = Color(0xFFA855F7);
  static const purple600 = Color(0xFF9333EA);

  // Pink
  static const pink100 = Color(0xFFFCE7F3);
  static const pink600 = Color(0xFFDB2777);

  // Amber
  static const amber100 = Color(0xFFFEF3C7);
  static const amber500 = Color(0xFFF59E0B);
  static const amber600 = Color(0xFFD97706);

  // ─────────────────────────────
  // 🧠 Text / Content Colors
  // ─────────────────────────────

  static const textMuted = Color(0xFF9CA3AF); // was gray400
  static const textSecondary = Color(0xFF6B7280); // was gray500
  static const textBody = Color(0xFF374151); // was gray700
  static const textPrimary = Color(0xFF111827); // was gray900

  // ─────────────────────────────
  // 🟡 Bookmark (Verse highlight / notes)
  // ─────────────────────────────

  static const highlightBackground = Color(0xFFFFFBEB); // amber50
  static const highlightSoft = Color(0xFFFEF3C7); // amber100
  static const highlightText = Color(0xFF92400E); // amber800
  static const highlightStrongText = Color(0xFF78350F); // amber900

  // ─────────────────────────────
  // 🟢 Progress / Positive states (Page bookmarks)
  // ─────────────────────────────

  static const successSoft = Color(0xFFD1FAE5); // emerald100
  static const successText = Color(0xFF065F46); // emerald800

  // ─────────────────────────────
  // 🔴 Destructive actions
  // ─────────────────────────────

  static const danger = Color(0xFFDC2626); // red600wh
}
