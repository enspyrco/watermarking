import 'dart:async';

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

    detectionController = StreamController<Map<String, dynamic>>(
        onListen: _onDetectionListen,
        onPause: _onDetectionPause,
        onResume: _onDetectionResume,
        onCancel: _onDetectionCancel);

    images = <OriginalImageReference>[];
  }

  StreamController<List<OriginalImageReference>> originalsController;
  StreamController<Map<String, dynamic>> profileController;
  StreamController<Map<String, dynamic>> detectionController;
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

  void _onDetectionListen() {}
  void _onDetectionPause() {}
  void _onDetectionResume() {}
  void _onDetectionCancel() {}

  Stream<List<OriginalImageReference>> get originalsStream =>
      originalsController.stream;
  Stream<Map<String, dynamic>> get profileStream => profileController.stream;
  Stream<Map<String, dynamic>> get detectionStream =>
      detectionController.stream;

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

  void addOriginal(OriginalImageReference img) {
    images.add(img);
    originalsController.add(images);
  }

  String get nextId => (++idNum).toString();
}
