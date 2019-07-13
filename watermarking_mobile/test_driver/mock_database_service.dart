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
  int numIdsGenerated = 0;

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
    return database.detectionStream
        .map<ActionSetDetectionProgress>((Map<String, dynamic> data) =>
            ActionSetDetectionProgress(progress: 'progress', result: 'result'))
        .handleError((dynamic error) => ActionAddProblem(
            problem:
                Problem(type: ProblemType.images, message: error.toString())));
  }

  @override
  Stream<ActionSetOriginalImages> connectToOriginals() {
    return database.originalsStream
        .map<ActionSetOriginalImages>((List<OriginalImageReference> images) =>
            ActionSetOriginalImages(images: images))
        .handleError((dynamic error) => ActionAddProblem(
            problem:
                Problem(type: ProblemType.images, message: error.toString())));
  }

  @override
  Stream<dynamic> connectToProfile() {
    return database.profileStream
        .map<ActionSetProfile>((Map<String, dynamic> data) =>
            ActionSetProfile(name: data['name'], email: data['email']))
        .handleError((dynamic error) => ActionAddProblem(
            problem:
                Problem(type: ProblemType.profile, message: error.toString())));
  }

  @override
  String getDetectedImageEntryId() {
    numIdsGenerated++;
    return numIdsGenerated.toString();
  }

  @override
  Future<void> requestOriginalDelete(String entryId) {
    // TODO: implement requestOriginalDelete
    return null;
  }
}
