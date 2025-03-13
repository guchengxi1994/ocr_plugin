import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ocr_plugin_macos_platform_interface.dart';
import 'ocr_result.dart';

/// An implementation of [OcrPluginMacosPlatform] that uses method channels.
class MethodChannelOcrPluginMacos extends OcrPluginMacosPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ocr_plugin_macos');

  @override
  Future<List<OcrResult>> recognizeText(String imagePath) async {
    try {
      final List<dynamic> result = await methodChannel.invokeMethod(
        'recognizeTextWithPosition',
        {'imagePath': imagePath},
      );
      return result
          .map((e) => OcrResult.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } on PlatformException catch (e) {
      print('OCR failed: ${e.details}');
      throw Exception('OCR failed: ${e.message}');
    }
  }
}
