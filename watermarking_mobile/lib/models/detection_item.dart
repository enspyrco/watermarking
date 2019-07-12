import 'package:watermarking_mobile/models/extracted_image_reference.dart';
import 'package:watermarking_mobile/utilities/hash_utilities.dart';

enum ProcessExtractedImageEvent {
  started,
  processed,
}

class DetectionItem {
  DetectionItem({
    this.id,
    this.started,
    this.originalId,
    this.extractedRef,
    this.progress,
    this.result,
  });

  final String id;
  final DateTime started;
  final String originalId;
  final ExtractedImageReference extractedRef;
  final String progress;
  final String result;

  DetectionItem copyWith({
    final String id,
    final DateTime started,
    final String originalId,
    final ExtractedImageReference extractedRef,
    final String progress,
    final String result,
  }) {
    return DetectionItem(
      id: id ?? this.id,
      started: started ?? this.started,
      originalId: originalId ?? this.originalId,
      extractedRef: extractedRef ?? this.extractedRef,
      progress: progress ?? this.progress,
      result: result ?? this.result,
    );
  }

  @override
  int get hashCode => hashObjects([
        this.id,
        this.started,
        this.originalId,
        this.extractedRef,
        this.progress,
        this.result,
      ]);

  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          id == other.id &&
          started == other.started &&
          originalId == other.originalId &&
          extractedRef == other.extractedRef &&
          progress == other.progress &&
          result == other.result;

  @override
  String toString() {
    return 'ImagesViewModel{id: $id, started: $started, originalId: $originalId, extractedRef: $extractedRef, progress: $progress, result: $result}';
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'started': started,
        'originalId': originalId,
        'extractedRef': extractedRef,
        'progress': progress,
        'result': result,
      };
}
