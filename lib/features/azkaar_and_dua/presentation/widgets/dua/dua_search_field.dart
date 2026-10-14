import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/theme/app_theme.dart';

class DuaSearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const DuaSearchField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : const Color(0xFFF0F5F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : Colors.black12,
        ),
      ),
      child: TextField(
        onChanged: (value) => onChanged(value.trim()),
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? AppTheme.darkTextPrimary : Colors.black87,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: "Search duas by title, meaning, or category...",
          hintStyle: TextStyle(
            color: isDark ? AppTheme.darkTextSecondary : Colors.black38,
            fontSize: 12,
          ),
          prefixIcon: Icon(
            LucideIcons.search,
            color: isDark ? AppTheme.darkTextSecondary : Colors.black38,
            size: 16,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
