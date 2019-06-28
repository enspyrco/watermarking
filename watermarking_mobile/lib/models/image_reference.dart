import 'package:watermarking_mobile/utilities/hash_utilities.dart';
import 'package:watermarking_mobile/utilities/string_utilities.dart';

class ImageReference {
  ImageReference({this.id, this.url});

  String id;
  String url;

  ImageReference copyWith({final String id, final String url}) {
    return ImageReference(id: id ?? this.id, url: url ?? this.url);
  }

  @override
  int get hashCode => hash2(id, url);

  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType && id == other.id && url == other.url;

  @override
  String toString() {
    final String trimmedUrl = trimToLast(15, url);
    return 'ImageReference{uid: $id, url: $trimmedUrl}';
  }

  Map<String, dynamic> toJson() => <String, dynamic>{'id': id, 'url': url};
}
