import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'package:quran_app/core/database/database_helper.dart';
import 'package:quran_app/features/audio/data/reciters_list.dart';
import 'package:quran_app/features/audio/domain/models/Reciters.dart';
import 'package:quran_app/features/audio/presentation/state/repeat_states.dart';

import '../../../quran/domain/models/surah.dart';
import '../../../quran/presentation/state/quran_providers.dart';
import 'audio_service.dart';

// =============================================================================
// AUDIO SERVICE PROVIDER
// =============================================================================

final audioServiceProvider = Provider<QuranAudioService>((ref) {
  final service = QuranAudioService();

  unawaited(service.init(ref));

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

// =============================================================================
// AUDIO PLAYER STATE STREAM
// =============================================================================

final audioStreamProvider = StreamProvider<PlayerState>((ref) {
  final streamService = ref.watch(audioServiceProvider);
  return streamService.player.playerStateStream;
});

// =============================================================================
// RECITERS
// =============================================================================

final recitersListProvider = Provider<List<Reciter>>((ref) {
  return reciters;
});

// =============================================================================
// SEARCH QUERY
// =============================================================================

final recitersSearchQueryProvider = StateProvider<String>((ref) => '');

// =============================================================================
// FILTERED RECITERS
// =============================================================================

final filteredRecitersProvider = Provider<List<Reciter>>((ref) {
  final recitersList = ref.watch(recitersListProvider);
  final searchQuery = ref.watch(recitersSearchQueryProvider).toLowerCase();

  if (searchQuery.isEmpty) {
    return recitersList;
  }

  return recitersList.where((reciter) {
    return reciter.name.toLowerCase().contains(searchQuery) ||
        reciter.country.toLowerCase().contains(searchQuery) ||
        reciter.arabicName.contains(searchQuery) ||
        reciter.style.toLowerCase().contains(searchQuery);
  }).toList();
});

// =============================================================================
// SELECTED RECITER
// =============================================================================

final selectedReciterProvider = StateProvider<Reciter?>((ref) => null);

// =============================================================================
// SELECTED SURAH INDEX
// =============================================================================

final selectedSurahIndexProvider = StateProvider<int?>((ref) => 0);

// =============================================================================
// SELECTED AUDIO SURAH
// =============================================================================

final selectedAudioSurahProvider = Provider<Surah?>((ref) {
  final index = ref.watch(selectedSurahIndexProvider);
  final surahsAsync = ref.watch(surahListProvider);

  if (surahsAsync is AsyncData<List<Surah>> && index != null && index >= 0) {
    final surahs = surahsAsync.value;
    if (index < surahs.length) {
      return surahs[index];
    }
  }

  return null;
});

// =============================================================================
// REPEAT MODE
// =============================================================================

final repeatModeProvider = StateProvider<RepeatStates>(
  (ref) => RepeatStates.off,
);

// =============================================================================
// VOLUME
// =============================================================================

final volumeProvider = StateProvider<double>((ref) => 0.7);

// =============================================================================
// DEFAULT RECITER
// =============================================================================

class DefaultReciterNotifier extends StateNotifier<Reciter?> {
  DefaultReciterNotifier() : super(_initialReciter) {
    _loadSaved();
  }

  static final Reciter _initialReciter = reciters.firstWhere(
    (r) => r.id == 'abu_bakr_shaatree',
    orElse: () => reciters.first,
  );

  Future<void> _loadSaved() async {
    try {
      final savedId = await DatabaseHelper.instance.getSetting(
        'default_reciter_id',
      );

      if (savedId != null && savedId.isNotEmpty) {
        final found = reciters.firstWhere(
          (r) => r.id == savedId,
          orElse: () => _initialReciter,
        );
        state = found;
      }
    } catch (_) {
      // Keep initial reciter if loading fails.
    }
  }

  Future<void> setReciter(Reciter reciter) async {
    state = reciter;
    await DatabaseHelper.instance.setSetting('default_reciter_id', reciter.id);
  }
}

final defaultReciterProvider =
    StateNotifierProvider<DefaultReciterNotifier, Reciter?>(
      (ref) => DefaultReciterNotifier(),
    );
