import 'dart:io';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class AudioArtworkHelper {
  static final Map<String, Uri> _cachedFileUris = {};

  /// Converts a local Flutter asset (e.g., 'assets/reciters/alafasy.jpg')
  /// into a persistent local file:// URI that audio_service and Android
  /// notification managers can load natively without triggering an HTTP network fetch.
  static Future<Uri?> getLocalAssetFileUri(String rawAssetPath) async {
    try {
      final cleanPath = rawAssetPath.startsWith('/')
          ? rawAssetPath.substring(1)
          : rawAssetPath;

      final assetKey = cleanPath.startsWith('assets/')
          ? cleanPath
          : 'assets/$cleanPath';

      if (_cachedFileUris.containsKey(assetKey)) {
        return _cachedFileUris[assetKey];
      }

      final byteData = await rootBundle.load(assetKey);
      final bytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final fileName = assetKey.split('/').last;
      final file = File('${tempDir.path}/$fileName');

      if (!await file.exists()) {
        await file.writeAsBytes(bytes, flush: true);
      }

      final fileUri = file.uri;
      _cachedFileUris[assetKey] = fileUri;
      return fileUri;
    } catch (e) {
      debugPrint('⚠️ Failed to resolve local artwork asset file: $e');
      return null;
    }
  }
}
