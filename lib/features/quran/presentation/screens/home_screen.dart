import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_app/features/prayer_times/presentation/states/prayer_time_provider.dart';
import 'package:quran_app/features/quran/presentation/widgets/home_widgets/body_section.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/home_widgets/header_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: CustomScrollView(
          slivers: [_buildHeader(), _buildBody()],
        ),
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: selectedIndex,
        onTap: (index) {
          ref.invalidate(locationProvider);

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

  SliverAppBar _buildHeader() {
    return const SliverAppBar(
      expandedHeight: 200,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      forceElevated: false,
      scrolledUnderElevation: 0,
      elevation: 0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(background: HeaderSection()),
    );
  }

  SliverList _buildBody() {
    return SliverList(delegate: SliverChildListDelegate(const [BodySection()]));
  }
}
