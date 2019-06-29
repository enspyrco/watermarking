import 'package:watermarking_mobile/utilities/hash_utilities.dart';
import 'package:watermarking_mobile/utilities/string_utilities.dart';

class ImageReference {
  ImageReference({this.id, this.name, this.url});

  String id;
  String name;
  String url;

  ImageReference copyWith(
      {final String id, final String name, final String url}) {
    return ImageReference(
        id: id ?? this.id, name: name ?? this.name, url: url ?? this.url);
  }

  @override
  int get hashCode => hash3(id, name, url);

  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          url == other.url;

  @override
  String toString() {
    final String trimmedUrl = trimToLast(15, url);
    return 'ImageReference{uid: $id, name: $name, url: $trimmedUrl}';
  }

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'id': id, 'name': name, 'url': url};
}
