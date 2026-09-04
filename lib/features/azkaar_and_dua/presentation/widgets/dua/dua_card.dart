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
    final isWitr = dua.categoryType == 'witr';

    final formattedSubject = isWitr
        ? 'Qunoot & Supplication'
        : (dua.subject.isNotEmpty
            ? '${dua.subject[0].toUpperCase()}${dua.subject.substring(1)}'
            : 'General');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedSubject,
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
                        color: AppColors.emerald100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isWitr ? "Witr & Qunoot" : "Quran",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.emerald600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
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
                          behavior: SnackBarBehavior.floating,
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

          /// Arabic text
          Text(
            dua.arabic,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: "Uthmanic",
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 14),

          /// Transliteration
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

          /// Translation
          Text(
            dua.translation,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          /// Reference / Source
          Text(
            isWitr
                ? (dua.source ?? "Hadith / Sunnah")
                : "Quran ${dua.surahNum}:${dua.ayahNum}",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.emerald600,
            ),
          ),
        ],
      ),
    );
  }
}
