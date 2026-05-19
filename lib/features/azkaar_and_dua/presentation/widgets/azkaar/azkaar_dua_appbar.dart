import 'package:flutter/material.dart';

class AzkaarDuaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AzkaarDuaAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF009688), // Teal color from your image
      elevation: 0,
      leading: const BackButton(color: Colors.white),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Azkaar and Dua',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            'Daily remembrance and supplications',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
