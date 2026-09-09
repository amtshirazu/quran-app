import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasource/display_settings_service.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

final appLanguageProvider = StateNotifierProvider<AppLanguageNotifier, String>((ref) {
  return AppLanguageNotifier();
});

final streamingModeProvider = StateNotifierProvider<StreamingModeNotifier, bool>((ref) {
  return StreamingModeNotifier();
});

final quranScriptProvider =
    StateNotifierProvider<QuranScriptNotifier, String>((ref) {
  return QuranScriptNotifier();
});

final ayahTextSizeProvider =
    StateNotifierProvider<AyahTextSizeNotifier, double>((ref) {
  return AyahTextSizeNotifier();
});

final translationTextSizeProvider =
    StateNotifierProvider<TranslationTextSizeNotifier, double>((ref) {
  return TranslationTextSizeNotifier();
});

final transliterationTextSizeProvider =
    StateNotifierProvider<TransliterationTextSizeNotifier, double>((ref) {
  return TransliterationTextSizeNotifier();
});

final referenceTextSizeProvider =
    StateNotifierProvider<ReferenceTextSizeNotifier, double>((ref) {
  return ReferenceTextSizeNotifier();
});

final showAyahBeforeTranslationProvider =
    StateNotifierProvider<AyahBeforeTranslationNotifier, bool>((ref) {
  return AyahBeforeTranslationNotifier();
});
