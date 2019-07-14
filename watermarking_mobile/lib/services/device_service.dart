import 'dart:io';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

class DeviceService {
  DeviceService();

  static const platform = const MethodChannel('watermarking.enspyr.co/detect');

  Future<List<String>> performExtraction(
      {@required int width, @required int height}) async {
    List<String> paths = await platform
        .invokeListMethod('startDetection', {'width': width, 'height': height});
    platform.invokeMethod('dismiss');
    return paths;
  }

  Future<int> findFileSize({@required String path}) {
    return File(path).length();
  }
}
