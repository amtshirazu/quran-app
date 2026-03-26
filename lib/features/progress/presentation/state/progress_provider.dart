import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/features/progress/data/local/progress_service.dart';




final progressServiceProvider = Provider<ProgressService>((ref) {
  return ProgressService();
});