import 'package:watermarking_mobile/models/image_reference.dart';
import 'package:watermarking_mobile/utilities/hash_utilities.dart';

class ImagesViewModel {
  ImagesViewModel({this.images});

  final List<ImageReference> images;

  ImagesViewModel copyWith(
      {final String id, final bool waiting, final String photoUrl}) {
    return ImagesViewModel(images: images ?? this.images);
  }

  @override
  int get hashCode => hashObjects(images);

  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType && images == other.images;

  @override
  String toString() {
    return 'ImagesViewModel{images: $images}';
  }

  Map<String, dynamic> toJson() => <String, dynamic>{'images': images};
}
