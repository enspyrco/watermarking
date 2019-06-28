import 'package:watermarking_mobile/utilities/hash_utilities.dart';
import 'package:watermarking_mobile/utilities/string_utilities.dart';

enum UploadingEvent {
  started,
  paused,
  resumed,
  progress,
  failure,
  success,
  processed,
}

enum UploadType {
  profilePic,
  gameVideo,
}

// TODO(nickm): I want to avoid null checks before percentage calculations
// - when NNBD lands we can use non-nullable type
// - until then, I will attempt to write code that means the values are never null
// TODO(nickm): I want to avoid doing non-zero check on totalBytes before the division
// - Dart has the infinity constant, maybe just test how the relevant views handle it

// Note: we can't give started a default value or set it in
// an initializer list without losing equality between objects
// created via copyWith
class UploadItem {
  UploadItem({
    this.type,
    this.id,
    this.latestEvent,
    this.filePath,
    this.bytesSent,
    this.totalBytes,
    this.started,
  });

  final UploadType type;
  final String id;
  final UploadingEvent latestEvent;
  final String filePath;
  final int bytesSent;
  final int totalBytes;
  final DateTime started;

  UploadItem copyWith(
      {UploadType type,
      String id,
      UploadingEvent latestEvent,
      String filePath,
      int bytesSent,
      int totalBytes,
      DateTime started}) {
    return UploadItem(
      type: type ?? this.type,
      id: id ?? this.id,
      latestEvent: latestEvent ?? this.latestEvent,
      filePath: filePath ?? this.filePath,
      bytesSent: bytesSent ?? this.bytesSent,
      totalBytes: totalBytes ?? this.totalBytes,
      started: started ?? this.started,
    );
  }

  @override
  int get hashCode =>
      hash7(type, id, latestEvent, filePath, bytesSent, totalBytes, started);

  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          type == other.type &&
          id == other.id &&
          latestEvent == other.latestEvent &&
          filePath == other.filePath &&
          bytesSent == other.bytesSent &&
          totalBytes == other.totalBytes &&
          started == other.started;

  @override
  String toString() {
    final String trimmedFilePath = trimToLast(15, filePath);
    return 'UploadingViewModel{type: $type, id: $id, $latestEvent, filePath: $trimmedFilePath, bytesSent: $bytesSent, totalBytes: $totalBytes, started: $started}';
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type.toString(),
        'id': id,
        'latestEvent': latestEvent.toString(),
        'filePath': filePath,
        'bytesSent': bytesSent,
        'totalBytes': totalBytes,
        'started': started
      };
}
