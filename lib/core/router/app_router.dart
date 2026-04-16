import 'package:go_router/go_router.dart';
import 'package:quran_app/features/audio/presentation/screens/reciters_selection_page.dart';
import 'package:quran_app/features/quran/presentation/screens/surah_detail_screen.dart';
import 'package:quran_app/features/quran/presentation/widgets/ayah_details_widget/non_paged/header_section.dart';
import '../../features/audio/presentation/screens/reciter_audio_screen.dart';
import '../../features/quran/presentation/screens/home_screen.dart';
import '../../features/quran/presentation/screens/read_quran_screen.dart';
import '../../features/quran/presentation/screens/settings_screen.dart';
import '../../features/progress/presentation/screens/profile_progress_screen.dart';





class AppRouter {

      static final GoRouter goRouter = GoRouter (
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
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
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileProgressScreen(),
          ),
        ]
      );
}