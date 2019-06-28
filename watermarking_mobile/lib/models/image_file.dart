import 'package:meta/meta.dart';
import 'package:watermarking_mobile/utilities/hash_utilities.dart';

/// [deleting] indicates a request has been made to delete the file and stop serving
class ImageFile {
  const ImageFile(
      {@required this.id, @required this.url, @required this.deleting});

  final String id;
  final String url;
  final bool deleting;

  ImageFile copyWith({String id, String url, bool deleting}) {
    return ImageFile(
      id: id ?? this.id,
      url: url ?? this.url,
      deleting: deleting ?? this.deleting,
    );
  }

  @override
  int get hashCode => hash3(id, url, deleting);

  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          id == other.id &&
          url == other.url &&
          deleting == other.deleting;

  @override
  String toString() {
    return 'ImageFile{id: $id, url: $url, deleting: $deleting}';
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'url': url,
        'deleting': deleting,
      };
}
