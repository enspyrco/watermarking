import 'package:watermarking_mobile/utilities/hash_utilities.dart';

enum UploadingEvent {
  started,
  paused,
  resumed,
  progress,
  failure,
  success,
}

class FileUpload {
  const FileUpload({
    this.started,
    this.bytesSent,
    this.latestEvent,
  });

  final DateTime started;
  final int bytesSent;
  final UploadingEvent latestEvent;

  FileUpload copyWith(
      {DateTime started, int bytesSent, UploadingEvent latestEvent}) {
    return FileUpload(
        started: started ?? this.started,
        bytesSent: bytesSent ?? this.bytesSent,
        latestEvent: latestEvent ?? this.latestEvent);
  }

  @override
  int get hashCode => hash3(started, bytesSent, latestEvent);

  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          started == other.started &&
          bytesSent == other.bytesSent &&
          latestEvent == other.latestEvent;

  @override
  String toString() {
    return 'FileUpload{startded: $started, bytesSent: $bytesSent, latestEvent: $latestEvent}';
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'started': started?.toIso8601String(),
        'bytesSent': bytesSent,
        'latestEvent': latestEvent,
      };
}
