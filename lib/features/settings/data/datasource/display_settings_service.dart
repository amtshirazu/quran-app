import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_helper.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    try {
      final raw = await DatabaseHelper.instance.getSetting('dark_mode');
      if (raw == 'true') {
        state = ThemeMode.dark;
      } else {
        state = ThemeMode.light;
      }
    } catch (_) {}
  }

  Future<void> toggleDarkMode(bool isDark) async {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
    await DatabaseHelper.instance.setSetting('dark_mode', isDark ? 'true' : 'false');
  }
}

/// App Language Notifier ('en', 'tr', 'fr')
class AppLanguageNotifier extends StateNotifier<String> {
  AppLanguageNotifier() : super('en') {
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    try {
      final saved = await DatabaseHelper.instance.getSetting('app_language');
      if (saved != null && (saved == 'en' || saved == 'tr' || saved == 'fr')) {
        state = saved;
      }
    } catch (_) {}
  }

  Future<void> setLanguage(String langCode) async {
    state = langCode;
    await DatabaseHelper.instance.setSetting('app_language', langCode);
  }
}

/// Streaming Mode Notifier (Default: false)
class StreamingModeNotifier extends StateNotifier<bool> {
  StreamingModeNotifier() : super(false) {
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    try {
      final saved = await DatabaseHelper.instance.getSetting('streaming_mode');
      if (saved != null) {
        state = saved == 'true';
      }
    } catch (_) {}
  }

  Future<void> toggleStreaming(bool value) async {
    state = value;
    await DatabaseHelper.instance.setSetting('streaming_mode', value ? 'true' : 'false');
  }
}

/// Quran Script Notifier ('Uthmanic' vs 'IndoPak')
class QuranScriptNotifier extends StateNotifier<String> {
  QuranScriptNotifier() : super('Uthmanic') {
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    try {
      final saved = await DatabaseHelper.instance.getSetting('quran_script');
      if (saved != null && (saved == 'Uthmanic' || saved == 'IndoPak')) {
        state = saved;
      }
    } catch (_) {}
  }

  Future<void> setScript(String script) async {
    state = script;
    await DatabaseHelper.instance.setSetting('quran_script', script);
  }
}

/// Ayah Text Size Notifier (Default: 18.0)
class AyahTextSizeNotifier extends StateNotifier<double> {
  AyahTextSizeNotifier() : super(18.0) {
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    try {
      final saved = await DatabaseHelper.instance.getSetting('ayah_text_size');
      if (saved != null) {
        final parsed = double.tryParse(saved);
        if (parsed != null && parsed >= 12 && parsed <= 36) {
          state = parsed;
        }
      }
    } catch (_) {}
  }

  Future<void> updateSize(double size) async {
    final clamped = size.clamp(12.0, 36.0);
    state = clamped;
    await DatabaseHelper.instance.setSetting('ayah_text_size', clamped.toString());
  }

  void increment() => updateSize(state + 1.0);
  void decrement() => updateSize(state - 1.0);
}

/// Translation Text Size Notifier (Default: 14.0)
class TranslationTextSizeNotifier extends StateNotifier<double> {
  TranslationTextSizeNotifier() : super(14.0) {
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    try {
      final saved = await DatabaseHelper.instance.getSetting('translation_text_size');
      if (saved != null) {
        final parsed = double.tryParse(saved);
        if (parsed != null && parsed >= 10 && parsed <= 28) {
          state = parsed;
        }
      }
    } catch (_) {}
  }

  Future<void> updateSize(double size) async {
    final clamped = size.clamp(10.0, 28.0);
    state = clamped;
    await DatabaseHelper.instance.setSetting('translation_text_size', clamped.toString());
  }

  void increment() => updateSize(state + 1.0);
  void decrement() => updateSize(state - 1.0);
}

/// Transliteration Text Size Notifier (Default: 13.0)
class TransliterationTextSizeNotifier extends StateNotifier<double> {
  TransliterationTextSizeNotifier() : super(13.0) {
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    try {
      final saved = await DatabaseHelper.instance.getSetting('transliteration_text_size');
      if (saved != null) {
        final parsed = double.tryParse(saved);
        if (parsed != null && parsed >= 10 && parsed <= 28) {
          state = parsed;
        }
      }
    } catch (_) {}
  }

  Future<void> updateSize(double size) async {
    final clamped = size.clamp(10.0, 28.0);
    state = clamped;
    await DatabaseHelper.instance.setSetting('transliteration_text_size', clamped.toString());
  }

  void increment() => updateSize(state + 1.0);
  void decrement() => updateSize(state - 1.0);
}

/// Reference Text Size Notifier (Default: 12.0)
class ReferenceTextSizeNotifier extends StateNotifier<double> {
  ReferenceTextSizeNotifier() : super(12.0) {
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    try {
      final saved = await DatabaseHelper.instance.getSetting('reference_text_size');
      if (saved != null) {
        final parsed = double.tryParse(saved);
        if (parsed != null && parsed >= 9 && parsed <= 24) {
          state = parsed;
        }
      }
    } catch (_) {}
  }

  Future<void> updateSize(double size) async {
    final clamped = size.clamp(9.0, 24.0);
    state = clamped;
    await DatabaseHelper.instance.setSetting('reference_text_size', clamped.toString());
  }

  void increment() => updateSize(state + 1.0);
  void decrement() => updateSize(state - 1.0);
}

/// Ayah Before Translation Notifier (Default: true)
class AyahBeforeTranslationNotifier extends StateNotifier<bool> {
  AyahBeforeTranslationNotifier() : super(true) {
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    try {
      final saved = await DatabaseHelper.instance.getSetting('show_ayah_before');
      if (saved != null) {
        state = saved == 'true';
      }
    } catch (_) {}
  }

  Future<void> toggle(bool value) async {
    state = value;
    await DatabaseHelper.instance.setSetting('show_ayah_before', value ? 'true' : 'false');
  }
}
