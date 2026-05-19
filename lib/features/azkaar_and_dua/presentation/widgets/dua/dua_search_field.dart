import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DuaSearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const DuaSearchField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12.withOpacity(0.05)),
      ),
      child: TextField(
        onChanged: (value) => onChanged(value.trim()),
        decoration: const InputDecoration(
          hintText: "Search duas by title, meaning, or category...",
          hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
          prefixIcon: Icon(LucideIcons.search, color: Colors.black38, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
