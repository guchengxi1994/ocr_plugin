import 'package:ocr_plugin_macos/ocr_result.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ocr_plugin_macos_method_channel.dart';

abstract class OcrPluginMacosPlatform extends PlatformInterface {
  /// Constructs a OcrPluginMacosPlatform.
  OcrPluginMacosPlatform() : super(token: _token);

  static final Object _token = Object();

  static OcrPluginMacosPlatform _instance = MethodChannelOcrPluginMacos();

  /// The default instance of [OcrPluginMacosPlatform] to use.
  ///
  /// Defaults to [MethodChannelOcrPluginMacos].
  static OcrPluginMacosPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [OcrPluginMacosPlatform] when
  /// they register themselves.
  static set instance(OcrPluginMacosPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<List<OcrResult>> recognizeText(String imagePath) {
    throw UnimplementedError('recognizeText() has not been implemented.');
  }
}
