import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/features/azkaar_and_dua/domain/model/quranic_dua.dart';

class DuaCard extends StatelessWidget {
  final QuranicDua dua;

  const DuaCard({super.key, required this.dua});

  @override
  Widget build(BuildContext context) {
    // Capitalize your internal subject categories nicely for display metadata pill tag
    final formattedSubject = dua.subject.isNotEmpty
        ? '${dua.subject[0].toUpperCase()}${dua.subject.substring(1)}'
        : 'General';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row containing title, action buttons, and source pill tags
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "For $formattedSubject",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.emerald500.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "Quran",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.emerald600,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // Implement your bookmark action hook logic here
                    },
                    icon: const Icon(
                      LucideIcons.heart,
                      size: 20,
                      color: Colors.black38,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(
                          text: "${dua.arabic}\n\n${dua.translation}",
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Dua copied to clipboard"),
                        ),
                      );
                    },
                    icon: const Icon(
                      LucideIcons.copy,
                      size: 20,
                      color: Colors.black38,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Arabic typography text field view block
          Text(
            dua.arabic,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: "Uthmanic", // Falls back gracefully if standard
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 14),

          // Transliteration text container block
          if (dua.transliteration != null &&
              dua.transliteration!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9F8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                dua.transliteration!,
                style: const TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // English explanation view layout
          Text(
            dua.translation,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          // Specific Verse Reference indicator line
          Text(
            "Quran ${dua.surahNum}:${dua.ayahNum}",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.emerald600,
            ),
          ),
        ],
      ),
    );
  }
}
