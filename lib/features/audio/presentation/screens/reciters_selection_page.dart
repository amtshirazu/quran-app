import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_app/features/audio/presentation/widgets/reciters_selection_widgets/quran_info.dart';

import '../../../quran/presentation/widgets/bottom_navbar.dart';
import '../state/audio_providers.dart';
import '../widgets/reciters_selection_widgets/header_section.dart';
import '../widgets/reciters_selection_widgets/reciters_card_list.dart';
import '../widgets/reciters_selection_widgets/search.dart';


class RecitersSelectionPage extends ConsumerStatefulWidget {
  const RecitersSelectionPage({super.key});

  @override
  ConsumerState<RecitersSelectionPage> createState() => RecitersSelectionPageState();
}

class RecitersSelectionPageState extends ConsumerState<RecitersSelectionPage> {
  int selectedIndex = 2;

  @override
  Widget build(BuildContext context) {

    final reciters = ref.watch(recitersListProvider);

    return Scaffold(
      body: Column(
          children: [
        
           QuranAudioHeader(
                recitersCount: reciters.length,
           ),
        
            Expanded(
              child: CustomScrollView(
                cacheExtent: 1000,
                slivers: [
        
                  SliverToBoxAdapter(
                    child: FeaturedRecitersCard(),
                  ),
        
        
        
                  SliverToBoxAdapter(
                    child: const SizedBox(height: 16),
                  ),
        
        
                  RecitersCardList(),
        
                  SliverToBoxAdapter(
                    child:  Padding(
                      padding: const EdgeInsets.all(12),
                      child: QuranAudioInfoCard(),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),

      bottomNavigationBar: BottomNavbar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });

          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/surahs');
              break;
            case 2:
              context.go('/audioHome');
              break;
            case 3:
              context.go('/search');
              break;
            case 4:
              context.go('/settings');
              break;
          }
        },
      ),
    );
  }
}