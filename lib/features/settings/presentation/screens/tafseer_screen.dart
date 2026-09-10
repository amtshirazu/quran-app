import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/quran/presentation/state/tafseer_provider.dart';
import 'package:quran_app/features/settings/domain/model/tafseer_model.dart';

class TafseerScreen extends ConsumerWidget {
  const TafseerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedTafseer = ref.watch(selectedTafseerProvider);

    final Map<String, List<TafseerModel>> grouped = {};
    for (final tafseer in kAllTafseers) {
      grouped.putIfAbsent(tafseer.language, () => []).add(tafseer);
    }

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF8F9FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkScaffold : null,
            gradient: isDark
                ? null
                : const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.deepGreen,
                      AppColors.emerald600,
                    ],
                  ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      LucideIcons.arrowLeft,
                      color: Colors.white,
                      size: 22,
                    ),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/settings');
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Tafseer Selection',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: grouped.entries.map((group) {
            final language = group.key;
            final items = group.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8, top: 12),
                  child: Text(
                    language.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkCategoryTitle : AppColors.emerald600,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppTheme.darkBorder : AppColors.gray200,
                    ),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      thickness: 1,
                      color: isDark ? AppTheme.darkBorder : const Color(0xFFF3F4F6),
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = selectedTafseer == item.dbFileName;

                      final BorderRadius itemRadius;
                      if (items.length == 1) {
                        itemRadius = BorderRadius.circular(16);
                      } else if (index == 0) {
                        itemRadius = const BorderRadius.vertical(top: Radius.circular(16));
                      } else if (index == items.length - 1) {
                        itemRadius = const BorderRadius.vertical(bottom: Radius.circular(16));
                      } else {
                        itemRadius = BorderRadius.zero;
                      }

                      return Material(
                        color: Colors.transparent,
                        borderRadius: itemRadius,
                        child: InkWell(
                          borderRadius: itemRadius,
                          onTap: () {
                            ref
                                .read(selectedTafseerProvider.notifier)
                                .setTafseer(item.dbFileName);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? AppTheme.darkTextPrimary
                                              : AppColors.gray900,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.description,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? AppTheme.darkTextSecondary
                                              : AppColors.gray600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppColors.emerald600,
                                    size: 22,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
