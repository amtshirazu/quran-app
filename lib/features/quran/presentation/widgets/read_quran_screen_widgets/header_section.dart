import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/features/quran/presentation/widgets/read_quran_screen_widgets/search.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../state/quran_providers.dart';





class ReadHeaderSection extends ConsumerWidget {
  const ReadHeaderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 50, 24, 20),
      decoration: const BoxDecoration(
        color: AppColors.emerald600,
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  ref.watch(searchQueryProvider.notifier).state = '';
                  context.go('/');
                },
                icon: Icon(
                  LucideIcons.arrowLeft,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              SizedBox(width: 16,),

              Column(
                children: [
                  Text(
                    "Read Quran",
                    style: textTheme.titleLarge,
                  ),

                  Text(
                    "114 Surahs",
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.gray400,
                    ),
                  ),
                ],
              )
            ],
          ),

          SizedBox(height: 20,),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SearchField(),
          ),
       ]
      ),
    );
  }
}
