import 'dart:io';
import 'package:meta/meta.dart';

class ImageFile {
  const ImageFile({@required this.path, @required this.totalBytes});

  final String path;
  final int totalBytes;
}

class DeviceService {
  DeviceService();
}
