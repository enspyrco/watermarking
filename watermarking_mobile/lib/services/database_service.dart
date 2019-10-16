import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:meta/meta.dart';
import 'package:watermarking_mobile/models/detection_item.dart';
import 'package:watermarking_mobile/models/original_image_reference.dart';
import 'package:watermarking_mobile/redux/actions.dart';

/// Note: Errors in streams are intentionally passed on and handled in middleware
class DatabaseService {
  DatabaseService();

  String userId;
  StreamSubscription<dynamic> originalsSubscription;
  StreamSubscription<dynamic> profileSubscription;
  StreamSubscription<dynamic> detectingSubscription;
  StreamSubscription<dynamic> detectionItemsSubscription;

  // create a document id that will be added as metadata to the upload
  // for use in a cloud function
  String getDetectionItemId() => FirebaseDatabase.instance
      .reference()
      .child('detection-items/$userId')
      .push()
      .key;

  Stream<dynamic> connectToOriginals() {
    return FirebaseDatabase.instance
        .reference()
        .child('original-images/$userId')
        .onValue
        .map<dynamic>((Event event) {
      // convert to a usable map
      // the unconverted type is '_InternalLinkedHashMap<dynamic, dynamic>'
      // TODO(nickm): determine if using Map.from is the best approach
      Map<String, dynamic> imagesMap =
          Map<String, dynamic>.from(event.snapshot.value);
      // use each key to access the data in the corresponding record
      List<OriginalImageReference> imagesList = imagesMap.keys
          .map<OriginalImageReference>((String key) => OriginalImageReference(
              id: key,
              name: imagesMap[key]["name"],
              filePath: imagesMap[key]["path"],
              url: imagesMap[key]["servingUrl"]))
          .toList();
      return ActionSetOriginalImages(images: imagesList);
    });
  }

  Future<dynamic> cancelOriginalsSubscription() {
    return (originalsSubscription == null)
        ? Future<dynamic>.value(null)
        : originalsSubscription.cancel();
  }

  Stream<dynamic> connectToProfile() {
    return FirebaseDatabase.instance
        .reference()
        .child('users/$userId')
        .onValue
        .map<dynamic>((Event event) => ActionSetProfile(
            name: event.snapshot.value['name'],
            email: event.snapshot.value['email']));
  }

  Future<dynamic> cancelProfileSubscription() {
    return (profileSubscription == null)
        ? Future<dynamic>.value(null)
        : profileSubscription.cancel();
  }

  /// Adds a flag to the images entry that will be picked up by a cloud
  /// function and go through the deletion sequence (remove file, stop serving)
  Future<void> requestOriginalDelete(String entryId) {
    return FirebaseDatabase.instance
        .reference()
        .child('original-images/$userId/$entryId')
        .update(<String, dynamic>{'delete': true});
  }

  Future<void> addDetectingEntry(
      {@required String itemId,
      @required String originalPath,
      @required String markedPath}) {
    FirebaseDatabase.instance.reference()
      ..child('detecting/incomplete/$userId').set({
        'itemId': itemId,
        'progress': 'Adding a detection task to the queue...',
        'isDetecting': true,
        'pathOriginal': originalPath,
        'pathMarked': markedPath,
        'attempts': 0
      })
      ..child('queue/tasks').push().set({
        '_state': 'download_original_spec_start',
        'uid': userId,
        'pathOriginal': originalPath,
        'pathMarked': markedPath,
      });

    return Future.value();
  }

  Stream<dynamic> connectToDetecting() {
    return FirebaseDatabase.instance
        .reference()
        .child('detecting/incomplete/$userId/')
        .onValue
        .map<dynamic>((Event event) {
      Map<String, dynamic> resultsMap;
      (event.snapshot.value['results'] == null)
          ? resultsMap = {'message': 'nullo'}
          : resultsMap =
              Map<String, dynamic>.from(event.snapshot.value["results"]);

      return ActionSetDetectingProgress(
          id: resultsMap['itemId'],
          progress: event.snapshot.value["progress"] ?? "null",
          result: resultsMap['message']);
    });
  }

  Future<dynamic> cancelDetectingSubscription() {
    return (detectingSubscription == null)
        ? Future<dynamic>.value(null)
        : detectingSubscription.cancel();
  }

  Stream<dynamic> connectToDetectionItems() {
    return FirebaseDatabase.instance
        .reference()
        .child('detection-items/$userId/')
        .onValue
        .map<dynamic>((Event event) {
      // the list that will be returned
      List<DetectionItem> list = [];

      // guard against no data
      if (event.snapshot.value == null)
        return ActionSetDetectionItems(items: list);

      Map<String, dynamic> itemsMap =
          Map<String, dynamic>.from(event.snapshot.value);
      for (String key in itemsMap.keys) {
        list.add(
          DetectionItem(
              id: key,
              progress: itemsMap[key]['progress'] ?? 'null',
              result: itemsMap[key]['result'] ?? 'null'),
        );
      }

      return ActionSetDetectionItems(items: list);
    });
  }

  Future<dynamic> cancelDetectionItemsSubscription() {
    return (detectionItemsSubscription == null)
        ? Future<dynamic>.value(null)
        : detectionItemsSubscription.cancel();
  }
}
