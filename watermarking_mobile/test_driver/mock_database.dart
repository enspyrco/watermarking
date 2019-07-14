import 'dart:async';

import 'package:watermarking_mobile/models/detection_item.dart';
import 'package:watermarking_mobile/models/original_image_reference.dart';

/// The [MockDatabase] is created in test_driver/app.dart and passed in to all
/// mocked services where the real service may interact with the backend database.
/// The [MockDatabaseService] listens to the [MockDatabase] object, which other mock
/// services may push data into, simulating the real backend.
///
class MockDatabase {
  MockDatabase() {
    profileController = StreamController<Map<String, dynamic>>(
        onListen: _onOriginalsListen,
        onPause: _onOriginalsPause,
        onResume: _onOriginalsResume,
        onCancel: _onOriginalsCancel);

    originalsController = StreamController<List<OriginalImageReference>>(
        onListen: _onProfileListen,
        onPause: _onProfilePause,
        onResume: _onProfileResume,
        onCancel: _onProfileCancel);

    detectingController = StreamController<Map<String, dynamic>>(
        onListen: _onDetectingListen,
        onPause: _onDetectingPause,
        onResume: _onDetectingResume,
        onCancel: _onDetectingCancel);

    detectionItemsController = StreamController<List<DetectionItem>>(
        onListen: _onDetectionItemsListen,
        onPause: _onDetectionItemsPause,
        onResume: _onDetectionItemsResume,
        onCancel: _onDetectionItemsCancel);

    images = <OriginalImageReference>[];
  }

  StreamController<List<OriginalImageReference>> originalsController;
  StreamController<List<DetectionItem>> detectionItemsController;
  StreamController<Map<String, dynamic>> profileController;
  StreamController<Map<String, dynamic>> detectingController;
  List<OriginalImageReference> images;

  int idNum = 0; // when an id is requested we give the next integer as a string

  void _onOriginalsListen() {
    addTestOriginal();
  }

  void _onOriginalsPause() {}
  void _onOriginalsResume() {}
  void _onOriginalsCancel() {}

  void _onProfileListen() {}
  void _onProfilePause() {}
  void _onProfileResume() {}
  void _onProfileCancel() {}

  void _onDetectingListen() {}
  void _onDetectingPause() {}
  void _onDetectingResume() {}
  void _onDetectingCancel() {}

  void _onDetectionItemsListen() {
    addTestDetectionItem();
  }

  void _onDetectionItemsPause() {}
  void _onDetectionItemsResume() {}
  void _onDetectionItemsCancel() {}

  Stream<List<OriginalImageReference>> get originalsStream =>
      originalsController.stream;
  Stream<Map<String, dynamic>> get profileStream => profileController.stream;
  Stream<Map<String, dynamic>> get detectingStream =>
      detectingController.stream;
  Stream<List<DetectionItem>> get detectionItemsStream =>
      detectionItemsController.stream;

  void addTestOriginal() {
    const OriginalImageReference img = OriginalImageReference(
        id: '0',
        name: 'name',
        filePath: 'path',
        url:
            'https://lh4.googleusercontent.com/-q5LxfJgDNZU/AAAAAAAAAAI/AAAAAAAABCc/Qg-SpkylHCA/photo.jpg');
    images.add(img);
    originalsController.add(<OriginalImageReference>[img]);
  }

  void addTestDetectionItem() {
    DetectionItem item = DetectionItem(
        started: DateTime.now(),
        id: '0',
        originalId: '0',
        progress: 'progress',
        result: 'result');
    detectionItemsController.add(<DetectionItem>[item]);
  }

  void addOriginal(OriginalImageReference img) {
    images.add(img);
    originalsController.add(images);
  }

  String get nextId => (++idNum).toString();
}
