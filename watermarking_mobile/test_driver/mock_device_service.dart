import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:watermarking_mobile/services/device_service.dart';

class MockDeviceService implements DeviceService {
  Future<File> addAssetToFileSystem() async {
    final ByteData bytes =
        await rootBundle.load('assets/transparent_logo_300x300.png');
    final ByteBuffer buffer = bytes.buffer;
    final String dir = (await getApplicationDocumentsDirectory()).path;
    return File('$dir/logoImage').writeAsBytes(
        buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
  }
}
