import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:watermarking_mobile/models/image_reference.dart';
import 'package:watermarking_mobile/redux/actions.dart';

/// Note: Errors in streams are intentionally passed on and handled in middleware
class DatabaseService {
  DatabaseService();

  String userId;
  StreamSubscription<dynamic> imagesSubscription;
  StreamSubscription<dynamic> profileSubscription;
  StreamSubscription<dynamic> watermarkDetectionProgressSubscription;

  // create a document id that will be added as metadata to the upload
  // for use in a cloud function
  String getDetectedImageEntryId() => FirebaseDatabase.instance
      .reference()
      .child('detected-images/$userId')
      .push()
      .key;

  Stream<dynamic> connectToImages() {
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
      List<ImageReference> imagesList = imagesMap.keys
          .map<ImageReference>((String key) => ImageReference(
              id: key,
              name: imagesMap[key]["name"],
              filePath: imagesMap[key]["path"],
              url: imagesMap[key]["servingUrl"]))
          .toList();
      return ActionSetImages(images: imagesList);
    });
  }

  Future<dynamic> cancelImagesSubscription() {
    return (imagesSubscription == null)
        ? Future<dynamic>.value(null)
        : imagesSubscription.cancel();
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
  Future<void> requestImageDelete(String entryId) {
    return FirebaseDatabase.instance
        .reference()
        .child('original-images/$userId/$entryId')
        .update(<String, dynamic>{'delete': true});
  }

  Future<void> addWatermarkDetectionEntry(
      String originalPath, String markedPath) {
    FirebaseDatabase.instance.reference()
      ..child('detecting/incomplete/$userId').set({
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

  Stream<dynamic> connectToWatermarkDetectionProgress() {
    return FirebaseDatabase.instance
        .reference()
        .child('detecting/incomplete/$userId/')
        .onValue
        .map<dynamic>((Event event) {
      Map<String, dynamic> resultsMap;
      (event.snapshot.value["results"] == null)
          ? resultsMap = {'message': 'nullo'}
          : resultsMap =
              Map<String, dynamic>.from(event.snapshot.value["results"]);

      return ActionSetWatermarkDetectionProgress(
          progress: event.snapshot.value["progress"] ?? "null",
          result: resultsMap['message']);
    });
  }

  Future<dynamic> cancelWatermarkDetectionProgressSubscription() {
    return (watermarkDetectionProgressSubscription == null)
        ? Future<dynamic>.value(null)
        : watermarkDetectionProgressSubscription.cancel();
  }
}
