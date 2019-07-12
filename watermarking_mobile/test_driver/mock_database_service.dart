import 'dart:async';

import 'package:watermarking_mobile/models/original_image_reference.dart';
import 'package:watermarking_mobile/models/problem.dart';
import 'package:watermarking_mobile/redux/actions.dart';
import 'package:watermarking_mobile/services/database_service.dart';

import 'mock_database.dart';

class MockDatabaseService implements DatabaseService {
  MockDatabaseService(this.database);

  // the mock database object is just a way for other mock services to create
  // behaviour that in production is done by cloud functions
  // eg. when a file is uploaded and a cloud function processes then adds an
  // entry to the firestore
  final MockDatabase database;

  @override
  StreamSubscription originalsSubscription;
  @override
  StreamSubscription profileSubscription;
  @override
  StreamSubscription detectionSubscription;
  String userId;

  @override
  Future<void> addDetectionEntry(String originalPath, String markedPath) {
    // TODO: implement addDetectionEntry
    return null;
  }

  @override
  Future cancelDetectionSubscription() {
    // TODO: implement cancelDetectionSubscription
    return null;
  }

  @override
  Future cancelOriginalsSubscription() {
    // TODO: implement cancelOriginalsSubscription
    return null;
  }

  @override
  Future cancelProfileSubscription() {
    // TODO: implement cancelProfileSubscription
    return null;
  }

  @override
  Stream connectToDetection() {
    // TODO: implement connectToDetection
    return null;
  }

  @override
  Stream connectToOriginals() {
    return database.originalsStream
        .map<ActionSetOriginalImages>((List<OriginalImageReference> images) =>
            ActionSetOriginalImages(images: images))
        .handleError((dynamic error) => ActionAddProblem(
            problem:
                Problem(type: ProblemType.images, message: error.toString())));
  }

  @override
  Stream connectToProfile() {
    // TODO: implement connectToProfile
    return null;
  }

  @override
  String getDetectedImageEntryId() {
    // TODO: implement getDetectedImageEntryId
    return null;
  }

  @override
  Future<void> requestOriginalDelete(String entryId) {
    // TODO: implement requestOriginalDelete
    return null;
  }
}
