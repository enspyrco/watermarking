import 'package:watermarking_mobile/utilities/hash_utilities.dart';

class DetectedImageViewModel {
  DetectedImageViewModel({
    this.detectedImagePath,
    this.watermarkDetectionProgress,
    this.watermarkDetectionResult,
  });

  final String detectedImagePath;
  final String watermarkDetectionProgress;
  final String watermarkDetectionResult;

  DetectedImageViewModel copyWith({
    final String detectedImagePath,
    final String watermarkDetectionProgress,
    final String watermarkDetectionResult,
  }) {
    return DetectedImageViewModel(
      detectedImagePath: detectedImagePath ?? this.detectedImagePath,
      watermarkDetectionProgress:
          watermarkDetectionProgress ?? this.watermarkDetectionProgress,
      watermarkDetectionResult:
          watermarkDetectionResult ?? this.watermarkDetectionResult,
    );
  }

  @override
  int get hashCode => hash3(
      detectedImagePath, watermarkDetectionProgress, watermarkDetectionResult);

  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          detectedImagePath == other.detectedImagePath &&
          watermarkDetectionProgress == other.watermarkDetectionProgress &&
          watermarkDetectionResult == other.watermarkDetectionResult;

  @override
  String toString() {
    return 'ImagesViewModel{detectedImagePath: $detectedImagePath, watermarkDetectionProgress: $watermarkDetectionProgress, watermarkDetectionResult: $watermarkDetectionResult}';
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'detectedImagePath': detectedImagePath,
        'watermarkDetectionProgress': watermarkDetectionProgress,
        'watermarkDetectionResult': watermarkDetectionResult,
      };
}
