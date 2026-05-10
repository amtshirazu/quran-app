import 'package:go_router/go_router.dart';
import 'package:muslim_data_flutter/muslim_data_flutter.dart';
import 'package:quran_app/features/audio/presentation/screens/reciters_selection_page.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/screens/azkaar_categories_screen.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/screens/azkaar_chapters_screen.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/screens/azkaar_dua_screen.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/screens/azkaar_items_screen.dart';
import 'package:quran_app/features/bookmark/presentation/screens/bookmark_screen.dart';
import 'package:quran_app/features/prayer_times/presentation/screens/prayer_times_screen.dart';
import 'package:quran_app/features/quran/presentation/screens/surah_detail_screen.dart';
import 'package:quran_app/features/reflection/presentation/screens/reflection_screen.dart';
import '../../features/audio/presentation/screens/reciter_audio_screen.dart';
import '../../features/quran/presentation/screens/home_screen.dart';
import '../../features/quran/presentation/screens/read_quran_screen.dart';
import '../../features/quran/presentation/screens/settings_screen.dart';
import '../../features/progress/presentation/screens/profile_progress_screen.dart';

class AppRouter {
  static final GoRouter goRouter = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/surahs',
        builder: (context, state) => const ReadQuranScreen(),
      ),
      GoRoute(
        path: '/readAyah',
        builder: (context, state) => const SurahDetailScreen(),
      ),
      GoRoute(
        path: '/audioHome',
        builder: (context, state) => const RecitersSelectionPage(),
      ),
      GoRoute(
        path: '/audioSong',
        builder: (context, state) => const ReciterAudioScreen(),
      ),
      GoRoute(
        path: '/bookmarks',
        builder: (context, state) => const BookmarkScreen(),
      ),
      GoRoute(
        path: '/reflections',
        builder: (context, state) => const ReflectionScreen(),
      ),
      GoRoute(
        path: '/prayerTimes',
        builder: (context, state) => const PrayerTimesScreen(),
      ),
      GoRoute(
        path: '/azkaarAndDua',
        builder: (context, state) => const AzkaarDuaScreen(),
      ),
      GoRoute(
        path: '/azkaarCategories',
        builder: (context, state) => const AzkarCategoriesScreen(),
      ),
      GoRoute(
        path: '/azkaarChapters',
        builder: (context, state) =>
            AzkarChaptersScreen(category: state.extra as AzkarCategory),
      ),
      GoRoute(
        path: '/azkaarItems',
        builder: (context, state) =>
            AzkarItemsScreen(chapter: state.extra as AzkarChapter),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileProgressScreen(),
      ),
    ],
  );
}
