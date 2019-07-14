import 'dart:async';

import 'package:meta/meta.dart';
import 'package:watermarking_mobile/models/detection_item.dart';
import 'package:watermarking_mobile/models/extracted_image_reference.dart';
import 'package:watermarking_mobile/models/file_upload.dart';
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
  StreamSubscription detectingSubscription;
  @override
  StreamSubscription detectionItemsSubscription;

  String userId;
  int numIdsGenerated = 0;

  @override
  String getDetectionItemId() {
    numIdsGenerated++;
    return numIdsGenerated.toString();
  }

  @override
  Future<void> addDetectingEntry(
      {@required String itemId,
      @required String originalPath,
      @required String markedPath}) {
    // TODO: implement addDetectionEntry
    return null;
  }

  @override
  Future<void> requestOriginalDelete(String entryId) {
    // TODO: implement requestOriginalDelete
    return null;
  }

  @override
  Future cancelProfileSubscription() {
    // TODO: implement cancelProfileSubscription
    return null;
  }

  @override
  Future cancelOriginalsSubscription() {
    // TODO: implement cancelOriginalsSubscription
    return null;
  }

  @override
  Future cancelDetectingSubscription() {
    // TODO: implement cancelDetectionSubscription
    return null;
  }

  @override
  Future cancelDetectionItemsSubscription() {
    // TODO: implement cancelDetectionItemsSubscription
    return null;
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
  Stream<dynamic> connectToOriginals() {
    return database.originalsStream
        .map<ActionSetOriginalImages>((List<OriginalImageReference> images) =>
            ActionSetOriginalImages(images: images))
        .handleError((dynamic error) => ActionAddProblem(
            problem:
                Problem(type: ProblemType.images, message: error.toString())));
  }

  @override
  Stream<dynamic> connectToDetecting() {
    return database.detectingStream
        .map<ActionSetDetectingProgress>((Map<String, dynamic> data) =>
            ActionSetDetectingProgress(
                id: numIdsGenerated.toString(),
                progress: 'progress',
                result: 'result'))
        .handleError((dynamic error) => ActionAddProblem(
            problem:
                Problem(type: ProblemType.images, message: error.toString())));
  }

  @override
  Stream<dynamic> connectToDetectionItems() {
    return database.detectionItemsStream
        .map<ActionSetDetectionItems>((List<DetectionItem> items) =>
            ActionSetDetectionItems(items: items))
        .handleError((dynamic error) => ActionAddProblem(
            problem:
                Problem(type: ProblemType.profile, message: error.toString())));
  }
}
