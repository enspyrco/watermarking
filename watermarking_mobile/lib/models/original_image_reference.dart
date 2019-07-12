import 'package:watermarking_mobile/utilities/hash_utilities.dart';
import 'package:watermarking_mobile/utilities/string_utilities.dart';

class OriginalImageReference {
  const OriginalImageReference({this.id, this.name, this.filePath, this.url});

  final String id;
  final String name;
  final String filePath;
  final String url;

  OriginalImageReference copyWith(
      {final String id, final String name, String filePath, final String url}) {
    return OriginalImageReference(
        id: id ?? this.id,
        name: name ?? this.name,
        filePath: filePath ?? this.filePath,
        url: url ?? this.url);
  }

  @override
  int get hashCode => hash4(id, name, filePath, url);

  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          filePath == other.filePath &&
          url == other.url;

  @override
  String toString() {
    final String trimmedUrl = trimToLast(15, url);
    return 'ImageReference{uid: $id, name: $name, filePath: $filePath, url: $trimmedUrl}';
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'filePath': filePath,
        'url': url
      };
}
