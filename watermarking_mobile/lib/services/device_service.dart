import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';

class DeviceService {
  DeviceService();

  static const platform = const MethodChannel('watermarking.enspyr.co/detect');

  Future<String> performFakeExtraction(
      {@required int width, @required int height}) async {
    final ByteData bytes = await rootBundle.load('assets/lena.png');
    final ByteBuffer buffer = bytes.buffer;
    final String dir = (await getApplicationDocumentsDirectory()).path;
    await File('$dir/lena').writeAsBytes(
        buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
    return '$dir/lena';
  }

  Future<String> performExtraction(
      {@required int width, @required int height}) async {
    String path = await platform
        .invokeMethod('startDetection', {'width': width, 'height': height});
    platform.invokeMethod('dismiss');
    return path;
  }

  Future<int> findFileSize({@required String path}) {
    return File(path).length();
  }
}
