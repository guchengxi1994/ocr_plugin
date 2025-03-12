class OcrResult {
  final String text;
  final double x;
  final double y;
  final double width;
  final double height;

  OcrResult({
    required this.text,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory OcrResult.fromMap(Map<String, dynamic> map) {
    return OcrResult(
      text: map['text'],
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
      width: (map['width'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
    );
  }

  @override
  String toString() {
    return 'OcrResult(text: $text, x: $x, y: $y, width: $width, height: $height)';
  }
}
