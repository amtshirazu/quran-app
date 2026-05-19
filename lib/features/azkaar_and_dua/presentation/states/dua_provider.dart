import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/features/azkaar_and_dua/domain/model/quranic_dua.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/states/dua_service.dart';

// Exposes the database instance across the application
final quranicDuaServiceProvider = Provider<QuranicDuaDatabaseService>((ref) {
  return QuranicDuaDatabaseService();
});

// Fetches EVERY single Quranic Dua in the database
final allQuranicDuasProvider = FutureProvider<List<QuranicDua>>((ref) async {
  final service = ref.watch(quranicDuaServiceProvider);
  return await service.getAllDuas();
});

final filteredQuranicDuasProvider =
    FutureProvider.family<List<QuranicDua>, String>((ref, query) async {
      final service = ref.watch(quranicDuaServiceProvider);
      return await service.searchDuas(query);
    });
