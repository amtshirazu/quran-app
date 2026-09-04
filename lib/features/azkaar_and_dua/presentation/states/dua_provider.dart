import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/features/azkaar_and_dua/domain/model/quranic_dua.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/states/dua_service.dart';

export 'package:quran_app/features/azkaar_and_dua/presentation/states/dua_service.dart' show DuaCategory;

/// Exposes the database service instance
final duaServiceProvider = Provider<DuaDatabaseService>((ref) {
  return DuaDatabaseService();
});

/// Currently selected active category toggle
final selectedDuaCategoryProvider = StateProvider<DuaCategory>((ref) {
  return DuaCategory.quranic;
});

/// Fetches all duas for the active category toggle
final allDuasProvider = FutureProvider<List<QuranicDua>>((ref) async {
  final service = ref.watch(duaServiceProvider);
  final category = ref.watch(selectedDuaCategoryProvider);
  return await service.getDuasByCategory(category);
});

/// Filters/searches duas within the active category toggle
final filteredDuasProvider = FutureProvider.family<List<QuranicDua>, String>((ref, query) async {
  final service = ref.watch(duaServiceProvider);
  final category = ref.watch(selectedDuaCategoryProvider);
  return await service.searchDuasByCategory(category, query);
});
