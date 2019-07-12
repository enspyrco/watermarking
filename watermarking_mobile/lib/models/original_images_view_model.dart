import 'package:watermarking_mobile/models/original_image_reference.dart';
import 'package:watermarking_mobile/utilities/hash_utilities.dart';

// TODO(nickm): when the image reference contains the size,
// remove width and height from ImagesViewModel
class OriginalImagesViewModel {
  OriginalImagesViewModel({
    this.images,
    this.selectedImage,
    this.selectedWidth,
    this.selectedHeight,
  });

  final List<OriginalImageReference> images;
  final OriginalImageReference selectedImage;
  final int selectedWidth;
  final int selectedHeight;

  OriginalImagesViewModel copyWith({
    final List<OriginalImageReference> images,
    final OriginalImageReference selectedImage,
    final int selectedWidth,
    final int selectedHeight,
  }) {
    return OriginalImagesViewModel(
      images: images ?? this.images,
      selectedImage: selectedImage ?? this.selectedImage,
      selectedWidth: selectedWidth ?? this.selectedWidth,
      selectedHeight: selectedHeight ?? this.selectedHeight,
    );
  }

  @override
  int get hashCode =>
      hash4(hashObjects(images), selectedImage, selectedWidth, selectedHeight);

  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          images == other.images &&
          selectedImage == other.selectedImage &&
          selectedWidth == other.selectedWidth &&
          selectedHeight == other.selectedHeight;

  @override
  String toString() {
    return 'OriginalImagesViewModel{images: $images, selectedImage: $selectedImage, selectedWidth: $selectedWidth, selectedHeight: $selectedHeight}';
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'images': images,
        'selectedImage': selectedImage,
        'selectedWidth': selectedWidth,
        'selectedHeight': selectedHeight,
      };
}
