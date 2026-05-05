import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_app/features/quran/presentation/widgets/read_quran_screen_widgets/quick_access.dart';
import 'package:quran_app/features/quran/presentation/widgets/read_quran_screen_widgets/surah_list.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/read_quran_screen_widgets/header_section.dart';

class ReadQuranScreen extends StatefulWidget {
  const ReadQuranScreen({super.key});

  @override
  State<ReadQuranScreen> createState() => _ReadQuranScreenState();
}

class _ReadQuranScreenState extends State<ReadQuranScreen> {
  int selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.emerald50, Colors.white],
          ),
        ),

        child: Column(
          children: [
            ReadHeaderSection(),
            SizedBox(height: 20),
            Expanded(
              child: CustomScrollView(
                cacheExtent: 1000,
                slivers: [_quickAccess(), SurahList()],
              ),
            ),
          ],
        ),
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

SliverList _quickAccess() {
  return SliverList(delegate: SliverChildListDelegate([QuickAccess()]));
}
