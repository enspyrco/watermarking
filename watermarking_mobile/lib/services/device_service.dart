import 'package:flutter/services.dart';

class DeviceService {
  DeviceService();

  static const platform = const MethodChannel('watermarking.enspyr.co/detect');

  Future<List<String>> performExtraction(int width, int height) async {
    List<String> paths = await platform
        .invokeListMethod('startDetection', {'width': width, 'height': height});
    platform.invokeMethod('dismiss');
    return paths;
  }
}
