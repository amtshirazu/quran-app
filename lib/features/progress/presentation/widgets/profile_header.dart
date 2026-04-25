import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.name, this.since});

  final String name;
  final String? since;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.emerald600,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                onPressed: () => context.go('/'),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Profile & Progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          const CircleAvatar(
            radius: 42,
            backgroundColor: AppColors.emerald500,
            child: Icon(LucideIcons.user, size: 34, color: Colors.white),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (since != null && since!.isNotEmpty)
            Text(
              since!,
              style: const TextStyle(color: Color(0xFFD1FAE5), fontSize: 14),
            ),
        ],
      ),
    );
  }
}
