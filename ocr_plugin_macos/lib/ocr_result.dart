import 'dart:math';

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

extension Sort on List<OcrResult> {
  List<OcrResult> sortOcrResults(double lineThreshold) {
    if (isEmpty) return [];

    // 按 y 坐标排序，初步按从上到下排序
    sort((a, b) => a.y.compareTo(b.y));

    // 按行分组
    List<List<OcrResult>> lines = [];
    for (var result in this) {
      bool added = false;
      for (var line in lines) {
        if ((result.y - line.first.y).abs() <= lineThreshold) {
          line.add(result);
          added = true;
          break;
        }
      }
      if (!added) {
        lines.add([result]);
      }
    }

    // 每一行内部按 x 坐标排序
    for (var line in lines) {
      line.sort((a, b) => a.x.compareTo(b.x));
    }

    // 合并排序后的行
    return lines.expand((line) => line).toList();
  }
}

extension Merge on List<OcrResult> {
  List<OcrResult> clusterOcrResults({
    double mergeThresholdX = 30.0,
    double mergeThresholdY = 30.0,
  }) {
    if (isEmpty) return [];

    // 先进行聚类
    List<OcrResult> clusteredResults = _clusterOcrResults(
      this,
      mergeThresholdX,
      mergeThresholdY,
    );

    // 对聚类结果按从上到下、从左到右排序
    clusteredResults.sort((a, b) {
      if ((a.y - b.y).abs() < mergeThresholdY) {
        return a.x.compareTo(b.x); // 处于同一行，按 x 坐标排序
      }
      return a.y.compareTo(b.y); // 按 y 坐标排序（从上到下）
    });

    return clusteredResults;
  }
}

// 进行 OCR 结果的层次聚类
List<OcrResult> _clusterOcrResults(
  List<OcrResult> results,
  double mergeThresholdX,
  double mergeThresholdY,
) {
  List<OcrResult> clusteredResults = [];
  List<bool> merged = List.filled(results.length, false);

  for (int i = 0; i < results.length; i++) {
    if (merged[i]) continue;

    List<OcrResult> cluster = [];
    _dfsCluster(results, i, cluster, merged, mergeThresholdX, mergeThresholdY);
    clusteredResults.add(_mergeCluster(cluster));
  }

  return clusteredResults;
}

// 使用 DFS 进行聚类
void _dfsCluster(
  List<OcrResult> results,
  int index,
  List<OcrResult> cluster,
  List<bool> merged,
  double mergeThresholdX,
  double mergeThresholdY,
) {
  if (merged[index]) return;
  merged[index] = true;
  cluster.add(results[index]);

  for (int i = 0; i < results.length; i++) {
    if (!merged[i] &&
        _shouldMerge(
          results[index],
          results[i],
          mergeThresholdX,
          mergeThresholdY,
        )) {
      _dfsCluster(
        results,
        i,
        cluster,
        merged,
        mergeThresholdX,
        mergeThresholdY,
      );
    }
  }
}

// 判断两个文本块是否需要合并
bool _shouldMerge(
  OcrResult a,
  OcrResult b,
  double mergeThresholdX,
  double mergeThresholdY,
) {
  double dx = _minDistance(a.x, a.width, b.x, b.width);
  double dy = _minDistance(a.y, a.height, b.y, b.height);

  return dx < mergeThresholdX && dy < mergeThresholdY;
}

// 合并一个文本簇为单一的 OcrResult
OcrResult _mergeCluster(List<OcrResult> cluster) {
  if (cluster.isEmpty) throw ArgumentError("Cluster cannot be empty");

  double minX = cluster.map((r) => r.x).reduce((a, b) => a < b ? a : b);
  double minY = cluster.map((r) => r.y).reduce((a, b) => a < b ? a : b);
  double maxX = cluster
      .map((r) => r.x + r.width)
      .reduce((a, b) => a > b ? a : b);
  double maxY = cluster
      .map((r) => r.y + r.height)
      .reduce((a, b) => a > b ? a : b);

  String mergedText = cluster.map((r) => r.text).join(" "); // 用空格连接文本

  return OcrResult(
    text: mergedText,
    x: minX,
    y: minY,
    width: maxX - minX,
    height: maxY - minY,
  );
}

double _minDistance(double pos1, double size1, double pos2, double size2) {
  double end1 = pos1 + size1;
  double end2 = pos2 + size2;

  // 计算最小间距（如果重叠，则返回 0）
  return max(0, max(pos1, pos2) - min(end1, end2));
}
