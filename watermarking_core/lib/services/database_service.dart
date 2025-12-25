import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:watermarking_core/models/detection_item.dart';
import 'package:watermarking_core/models/original_image_reference.dart';
import 'package:watermarking_core/redux/actions.dart';

/// Note: Errors in streams are intentionally passed on and handled in middleware
class DatabaseService {
  DatabaseService();

  String? userId;
  StreamSubscription<dynamic>? originalsSubscription;
  StreamSubscription<dynamic>? profileSubscription;
  StreamSubscription<dynamic>? detectingSubscription;
  StreamSubscription<dynamic>? detectionItemsSubscription;

  String getDetectionItemId() => FirebaseDatabase.instance
      .ref()
      .child('detection-items/$userId')
      .push()
      .key!;

  Stream<dynamic> connectToOriginals() {
    return FirebaseDatabase.instance
        .ref()
        .child('original-images/$userId')
        .onValue
        .map<dynamic>((DatabaseEvent event) {
      final value = event.snapshot.value;
      if (value == null) {
        return ActionSetOriginalImages(images: []);
      }

      final Map<String, dynamic> imagesMap =
          Map<String, dynamic>.from(value as Map);
      final List<OriginalImageReference> imagesList = imagesMap.keys
          .map<OriginalImageReference>((String key) => OriginalImageReference(
              id: key,
              name: imagesMap[key]["name"] as String?,
              filePath: imagesMap[key]["path"] as String?,
              url: imagesMap[key]["servingUrl"] as String?))
          .toList();
      return ActionSetOriginalImages(images: imagesList);
    });
  }

  Future<dynamic> cancelOriginalsSubscription() {
    return originalsSubscription?.cancel() ?? Future<dynamic>.value(null);
  }

  Stream<dynamic> connectToProfile() {
    return FirebaseDatabase.instance
        .ref()
        .child('users/$userId')
        .onValue
        .map<dynamic>((DatabaseEvent event) {
      final value = event.snapshot.value;
      if (value == null) {
        return ActionSetProfile(name: '', email: '');
      }
      final data = value as Map;
      return ActionSetProfile(
          name: data['name'] as String? ?? '',
          email: data['email'] as String? ?? '');
    });
  }

  Future<dynamic> cancelProfileSubscription() {
    return profileSubscription?.cancel() ?? Future<dynamic>.value(null);
  }

  Future<void> requestOriginalDelete(String entryId) {
    return FirebaseDatabase.instance
        .ref()
        .child('original-images/$userId/$entryId')
        .update(<String, dynamic>{'delete': true});
  }

  /// Add an original image entry to the database
  Future<String> addOriginalImageEntry({
    required String name,
    required String path,
    required String url,
    required int width,
    required int height,
  }) async {
    final ref = FirebaseDatabase.instance
        .ref()
        .child('original-images/$userId')
        .push();

    await ref.set({
      'name': name,
      'path': path,
      'url': url,
      'servingUrl': url,
      'width': width,
      'height': height,
      'timestamp': ServerValue.timestamp,
    });

    // Also create a task to get serving URL
    await FirebaseDatabase.instance.ref().child('queue/tasks').push().set({
      '_state': 'get_serving_url_spec_start',
      'uid': userId,
      'imageId': ref.key,
      'path': path,
    });

    return ref.key!;
  }

  Future<void> addDetectingEntry({
    required String itemId,
    required String originalPath,
    required String markedPath,
  }) async {
    final ref = FirebaseDatabase.instance.ref();
    await ref.child('detecting/incomplete/$userId').set({
      'itemId': itemId,
      'progress': 'Adding a detection task to the queue...',
      'isDetecting': true,
      'pathOriginal': originalPath,
      'pathMarked': markedPath,
      'attempts': 0,
    });
    await ref.child('queue/tasks').push().set({
      '_state': 'download_original_spec_start',
      'uid': userId,
      'pathOriginal': originalPath,
      'pathMarked': markedPath,
    });
  }

  Stream<dynamic> connectToDetecting() {
    return FirebaseDatabase.instance
        .ref()
        .child('detecting/incomplete/$userId/')
        .onValue
        .map<dynamic>((DatabaseEvent event) {
      final value = event.snapshot.value;
      if (value == null) {
        return ActionSetDetectingProgress(
          id: '',
          progress: '',
          result: null,
        );
      }

      final data = value as Map;
      Map<String, dynamic>? resultsMap;
      if (data['results'] != null) {
        resultsMap = Map<String, dynamic>.from(data['results'] as Map);
      }

      return ActionSetDetectingProgress(
        id: data['itemId'] as String? ?? '',
        progress: data['progress'] as String? ?? '',
        result: resultsMap?['message'] as String?,
      );
    });
  }

  Future<dynamic> cancelDetectingSubscription() {
    return detectingSubscription?.cancel() ?? Future<dynamic>.value(null);
  }

  Stream<dynamic> connectToDetectionItems() {
    return FirebaseDatabase.instance
        .ref()
        .child('detection-items/$userId/')
        .onValue
        .map<dynamic>((DatabaseEvent event) {
      final List<DetectionItem> list = [];

      final value = event.snapshot.value;
      if (value == null) {
        return ActionSetDetectionItems(items: list);
      }

      final Map<String, dynamic> itemsMap =
          Map<String, dynamic>.from(value as Map);
      for (final String key in itemsMap.keys) {
        final item = itemsMap[key] as Map?;
        if (item != null) {
          list.add(
            DetectionItem(
                id: key,
                progress: item['progress'] as String? ?? '',
                result: item['result'] as String?),
          );
        }
      }

      return ActionSetDetectionItems(items: list);
    });
  }

  Future<dynamic> cancelDetectionItemsSubscription() {
    return detectionItemsSubscription?.cancel() ?? Future<dynamic>.value(null);
  }
}
