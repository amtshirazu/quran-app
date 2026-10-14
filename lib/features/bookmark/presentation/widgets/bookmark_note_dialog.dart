import 'package:flutter/material.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';

import '../../../../core/constants/app_spacing.dart';

Future<String?> showBookmarkDialog(
  BuildContext context, {
  required String title,
  required String subtitle,
  required bool isPageMode,
  String? initialNote,
}) {
  final controller = TextEditingController(text: initialNote ?? "");
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final String noteHint = isPageMode
      ? "Add a note to remember why this page is important (optional)"
      : "Add a note to remember why this verse is important (optional)";

  final String textFieldHint = isPageMode
      ? "e.g. Favorite Juz, specific topic, start of my journey..."
      : "e.g. Read when stressed, reminder for prayer, beautiful tafsir...";

  const colorEmerald = AppColors.emerald600;

  final textColor = isDark ? AppTheme.darkTextPrimary : const Color(0xFF111827);
  final subtextColor = isDark ? AppTheme.darkTextSecondary : const Color(0xFF71717A);
  final fieldBg = isDark ? AppTheme.darkScaffold : const Color(0xFFF9FAFB);
  final borderColor = isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB);

  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        surfaceTintColor: isDark ? AppTheme.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: isDark ? const BorderSide(color: AppTheme.darkBorder) : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppSpacing.size15,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.close,
                      color: subtextColor,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: colorEmerald,
                  fontWeight: FontWeight.w600,
                  fontSize: AppSpacing.size12,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                noteHint,
                style: TextStyle(color: subtextColor, fontSize: AppSpacing.size10),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 3,
                autofocus: true,
                style: TextStyle(fontSize: 14, color: textColor),
                decoration: InputDecoration(
                  hintText: textFieldHint,
                  hintStyle: TextStyle(
                    color: subtextColor,
                    fontSize: AppSpacing.size10,
                  ),
                  filled: true,
                  fillColor: fieldBg,
                  contentPadding: const EdgeInsets.all(14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: colorEmerald, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        side: BorderSide(color: borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: subtextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: AppSpacing.size10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        backgroundColor: colorEmerald,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context, controller.text.trim());
                      },
                      child: const Text(
                        "Save Bookmark",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppSpacing.size12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
