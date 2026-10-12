import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/features/prayer_times/presentation/states/prayer_time_provider.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../features/audio/presentation/state/audio_providers.dart';
import '../features/settings/presentation/state/display_settings_provider.dart';

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

    // CHANGE: removed `.init(ref as Ref<Object?>)`.
    //
    // `ref` in a ConsumerState is a WidgetRef, and casting a WidgetRef to
    // Ref is invalid (it throws a type error at runtime). It is also not
    // needed: audioServiceProvider already calls service.init(ref) itself
    // with the correct Ref the first time the provider is read.
    //
    // Reading the provider here just makes sure the service is created
    // (and initialized) at app start.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioServiceProvider);
    });

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(locationProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRouter.goRouter,
    );
  }
}