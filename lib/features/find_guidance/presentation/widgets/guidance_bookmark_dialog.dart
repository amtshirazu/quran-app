import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import '../../domain/model/guidance_verse.dart';

Future<String?> showGuidanceBookmarkDialog(
  BuildContext context, {
  required GuidanceVerse verse,
  String? initialNote,
}) {
  final controller = TextEditingController(text: initialNote ?? '');

  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Top Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEF2F2), // Light red/pink
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.heart,
                      color: Color(0xFFEF4444), // Red
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Save to Bookmarks',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gray900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${verse.surahName ?? 'Surah ${verse.surahNum}'} • Verse ${verse.ayahNum}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.gray500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3F4F6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.gray600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Light Emerald Verse Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.emerald50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    if (verse.arabicText != null &&
                        verse.arabicText!.isNotEmpty) ...[
                      Text(
                        verse.arabicText!,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontSize: 20,
                          height: 1.8,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray900,
                          fontFamily: 'Uthmanic',
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (verse.translation != null &&
                        verse.translation!.isNotEmpty) ...[
                      Text(
                        '"${verse.translation}"',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          fontStyle: FontStyle.italic,
                          color: AppColors.gray700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// "Add a note (optional)" Title
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Add a note ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray900,
                      ),
                    ),
                    TextSpan(
                      text: '(optional)',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              /// Note Input TextField
              TextField(
                controller: controller,
                minLines: 3,
                maxLines: 5,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.gray900,
                ),
                decoration: InputDecoration(
                  hintText:
                      'What does this verse mean to you? Why are you saving it?',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.gray400,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.emerald500, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.gray900,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.emerald600,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context, controller.text.trim());
                      },
                      icon: const Icon(
                        LucideIcons.heart,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Save Verse',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
