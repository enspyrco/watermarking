import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';

class ImageFile {
  const ImageFile({@required this.path, @required this.totalBytes});

  final String path;
  final int totalBytes;
}

class DeviceService {
  DeviceService();

  Future<ImageFile> selectFromGallery() async {
    final File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    return ImageFile(path: file.path, totalBytes: file.lengthSync());
  }

  Future<ImageFile> selectFromCamera() async {
    final File file = await ImagePicker.pickImage(source: ImageSource.camera);
    return ImageFile(path: file.path, totalBytes: file.lengthSync());
  }
}
