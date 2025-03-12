import 'package:ocr_plugin_macos/ocr_result.dart';

import 'ocr_plugin_macos_platform_interface.dart';

class OcrPluginMacos {
  Future<List<OcrResult>> recognizeText(String imagePath) async {
    return OcrPluginMacosPlatform.instance.recognizeText(imagePath);
  }
}
