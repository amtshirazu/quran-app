import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/features/prayer_times/presentation/states/prayer_time_provider.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../features/audio/presentation/state/audio_providers.dart';

class QuranApp extends ConsumerStatefulWidget {
  const QuranApp({super.key});

  @override
  ConsumerState<QuranApp> createState() => _QuranAppState();
}

class _QuranAppState extends ConsumerState<QuranApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    // Audio Initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioServiceProvider).init(ref);
    });

    // Lifecycle Observer to track when the app "Opens"
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // triggers "whenever the app opens" from the background
    if (state == AppLifecycleState.resumed) {
      // Refreshes location and prayer times
      ref.invalidate(locationProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.goRouter,
    );
  }
}
