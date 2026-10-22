import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import '../../../../core/constants/app_spacing.dart';
import '../state/search_provider.dart';

class SearchHeader extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearchSubmitted;
  final VoidCallback onClear;

  const SearchHeader({
    super.key,
    required this.controller,
    required this.onSearchSubmitted,
    required this.onClear,
  });

  @override
  ConsumerState<SearchHeader> createState() => _SearchHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(130);
}

class _SearchHeaderState extends ConsumerState<SearchHeader> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkScaffold : null,
        gradient: isDark
            ? null
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0F382C), Color(0xFF1B5E48)],
              ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    },
                    child: const Icon(
                      LucideIcons.arrowLeft,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Search Quran',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppSpacing.size16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(
                    color: isDark
                        ? AppTheme.darkBorder
                        : const Color(0xFFE5E7EB),
                  ),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withAlpha(12),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: TextField(
                  controller: widget.controller,
                  textInputAction: TextInputAction.search,
                  textAlignVertical: TextAlignVertical.center,
                  onSubmitted: (value) {
                    final trimmed = value.trim();
                    if (trimmed.length >= 2) {
                      widget.onSearchSubmitted(trimmed);
                    }
                  },
                  onChanged: (value) {
                    ref.read(activeSearchQueryProvider.notifier).state = value;
                  },
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText:
                        'Type surah, ayah, topic, or translation keyword...',
                    hintStyle: TextStyle(
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : const Color(0xFF9CA3AF),
                      fontSize: 12,
                    ),
                    prefixIcon: Icon(
                      LucideIcons.search,
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : const Color(0xFF6B7280),
                      size: 16,
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.controller.text.isNotEmpty)
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              Icons.close,
                              size: 16,
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : const Color(0xFF6B7280),
                            ),
                            onPressed: widget.onClear,
                          ),
                      ],
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}
