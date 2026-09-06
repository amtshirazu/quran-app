import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../state/search_provider.dart';

class SearchHeader extends ConsumerStatefulWidget implements PreferredSizeWidget {
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
  Size get preferredSize => const Size.fromHeight(145);
}

class _SearchHeaderState extends ConsumerState<SearchHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F382C), // Deep green
            Color(0xFF1B5E48), // Emerald green
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Top Title Row with Back Button
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
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Search Quran',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              /// White Rounded Search Input Field
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: widget.controller,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    final trimmed = value.trim();
                    if (trimmed.length >= 2) {
                      widget.onSearchSubmitted(trimmed);
                    }
                  },
                  onChanged: (value) {
                    ref.read(activeSearchQueryProvider.notifier).state = value;
                  },
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF111827),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type surah, ayah, topic, or translation keyword...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      LucideIcons.search,
                      color: Color(0xFF6B7280),
                      size: 18,
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.controller.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 18,
                              color: Color(0xFF6B7280),
                            ),
                            onPressed: widget.onClear,
                          ),
                        const Padding(
                          padding: EdgeInsets.only(right: 12.0),
                          child: Icon(
                            LucideIcons.mic,
                            color: Color(0xFF6B7280),
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
