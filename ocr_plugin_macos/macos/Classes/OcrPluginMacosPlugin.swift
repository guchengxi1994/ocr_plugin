import Cocoa
import FlutterMacOS
import Vision

public class OcrPluginMacosPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "ocr_plugin_macos", binaryMessenger: registrar.messenger)
    let instance = OcrPluginMacosPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "recognizeText" {
      guard let args = call.arguments as? [String: Any],
        let imagePath = args["imagePath"] as? String
      else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing imagePath", details: nil))
        return
      }
      recognizeText(from: imagePath, result: result)
    } else if call.method == "recognizeTextWithPosition" {
      guard let args = call.arguments as? [String: Any],
        let imagePath = args["imagePath"] as? String
      else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing imagePath", details: nil))
        return
      }
      recognizeTextWithPosition(from: imagePath, result: result)
    } else {
      result(FlutterMethodNotImplemented)
    }
  }

  private func recognizeText(from imagePath: String, result: @escaping FlutterResult) {
    // 检查文件是否存在
    if !FileManager.default.fileExists(atPath: imagePath) {
      result(
        FlutterError(code: "FILE_NOT_FOUND", message: "File does not exist", details: imagePath))
      return
    }
    let url = URL(fileURLWithPath: imagePath)

    do {
      let data = try Data(contentsOf: url)
      print("File size: \(data.count) bytes")  // 确保文件不是空的
    } catch {
      result(
        FlutterError(
          code: "FILE_READ_ERROR", message: "Cannot read file", details: error.localizedDescription)
      )
      return
    }

    let requestHandler = VNImageRequestHandler(url: url, options: [:])
    let request = VNRecognizeTextRequest { request, error in
      guard let observations = request.results as? [VNRecognizedTextObservation] else {
        result(
          FlutterError(
            code: "OCR_FAILED", message: "Failed to recognize text",
            details: error?.localizedDescription))
        return
      }

      var recognizedTexts: [[String: Any]] = []
      for observation in observations {
        if let text = observation.topCandidates(1).first?.string {
          let boundingBox = observation.boundingBox  // (x, y, width, height)

          recognizedTexts.append([
            "text": text,
            "x": boundingBox.origin.x,
            "y": boundingBox.origin.y,
            "width": boundingBox.width,
            "height": boundingBox.height,
          ])
        }
      }
      result(recognizedTexts)
    }

    // 🔥 设置支持的语言（添加中文支持）
    request.recognitionLanguages = ["zh-Hans", "zh-Hant", "en"]

    // 允许OCR识别更复杂的文本
    request.recognitionLevel = .accurate

    do {
      try requestHandler.perform([request])
    } catch {
      result(
        FlutterError(
          code: "OCR_EXCEPTION", message: "Failed to process image",
          details: error.localizedDescription))
    }
  }

  private func recognizeTextWithPosition(from imagePath: String, result: @escaping FlutterResult) {
    // 检查文件是否存在
    if !FileManager.default.fileExists(atPath: imagePath) {
      result(
        FlutterError(code: "FILE_NOT_FOUND", message: "File does not exist", details: imagePath))
      return
    }

    let url = URL(fileURLWithPath: imagePath)

    // 获取图像的宽高
    guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil),
      let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any],
      let width = properties[kCGImagePropertyPixelWidth] as? CGFloat,
      let height = properties[kCGImagePropertyPixelHeight] as? CGFloat
    else {
      result(
        FlutterError(
          code: "IMAGE_INFO_ERROR", message: "Failed to get image dimensions", details: nil))
      return
    }

    let requestHandler = VNImageRequestHandler(url: url, options: [:])
    let request = VNRecognizeTextRequest { request, error in
      guard let observations = request.results as? [VNRecognizedTextObservation] else {
        result(
          FlutterError(
            code: "OCR_FAILED", message: "Failed to recognize text",
            details: error?.localizedDescription))
        return
      }

      var recognizedTexts: [[String: Any]] = []
      for observation in observations {
        if let text = observation.topCandidates(1).first?.string {
          let boundingBox = observation.boundingBox  // 归一化 (x, y, width, height)

          // 🔥 转换为像素坐标
          let x = boundingBox.origin.x * width
          let y = (1 - boundingBox.origin.y - boundingBox.height) * height
          let boxWidth = boundingBox.width * width
          let boxHeight = boundingBox.height * height

          recognizedTexts.append([
            "text": text,
            "x": x,
            "y": y,
            "width": boxWidth,
            "height": boxHeight,
          ])
        }
      }
      result(recognizedTexts)
    }

    // 🔥 设置支持的语言（包含中文）
    request.recognitionLanguages = ["zh-Hans", "zh-Hant", "en"]

    // 允许OCR识别更复杂的文本
    request.recognitionLevel = .accurate

    do {
      try requestHandler.perform([request])
    } catch {
      result(
        FlutterError(
          code: "OCR_EXCEPTION", message: "Failed to process image",
          details: error.localizedDescription))
    }
  }
}
