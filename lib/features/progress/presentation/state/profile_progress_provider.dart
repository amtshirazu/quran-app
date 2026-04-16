import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileNameProvider = Provider<String>((ref) => 'Abdullah');
final profileSinceProvider = Provider<String>((ref) => 'Reading since Jan 2026');

final quranCompletionProvider = Provider<double>((ref) => 23.0);
final streakProvider = Provider<int>((ref) => 7);
final versesReadProvider = Provider<int>((ref) => 342);
final surahsReadProvider = Provider<int>((ref) => 14);

final motivationTitleProvider = Provider<String>((ref) => 'Keep Going!');
final motivationSubtitleProvider = Provider<String>((ref) =>
    "You're doing amazing. Continue your journey with the Quran.");
