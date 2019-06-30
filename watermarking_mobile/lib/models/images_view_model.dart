import 'package:watermarking_mobile/models/image_reference.dart';
import 'package:watermarking_mobile/utilities/hash_utilities.dart';

class ImagesViewModel {
  ImagesViewModel({this.images, this.selectedImage});

  final List<ImageReference> images;
  final ImageReference selectedImage;

  ImagesViewModel copyWith(
      {final List<ImageReference> images, final ImageReference selectedImage}) {
    return ImagesViewModel(
        images: images ?? this.images,
        selectedImage: selectedImage ?? this.selectedImage);
  }

  @override
  int get hashCode => hash2(hashObjects(images), selectedImage);

  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          images == other.images &&
          selectedImage == other.selectedImage;

  @override
  String toString() {
    return 'ImagesViewModel{images: $images, selectedImage: $selectedImage}';
  }

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'images': images, 'selectedImage': selectedImage};
}
