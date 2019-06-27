import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:watermarking_mobile/models/image_file.dart';
import 'package:watermarking_mobile/models/problem.dart';
import 'package:watermarking_mobile/redux/actions.dart';

class DatabaseService {
  DatabaseService();

  String userId;
  StreamSubscription<dynamic> imagesSubscription;

  Stream<dynamic> connectToImages() {
    return FirebaseDatabase.instance
        .reference()
        .child('original-images/$userId')
        .onValue
        .map<dynamic>(
            (Event event) => ActionSetImages(images: event.snapshot.value))
        .handleError((dynamic error) => ActionAddProblem(
            problem: Problem(
                type: ProblemType.profilePics, message: error.toString())));
  }

  Future<dynamic> cancelImagesSubscription() {
    return (imagesSubscription == null)
        ? Future<dynamic>.value(null)
        : imagesSubscription.cancel();
  }

  /// Adds a flag to the images entry that will be picked up by a cloud
  /// function and go through the deletion sequence (remove file, stop serving)
  Future<void> requestProfilePicDelete(String entryId) {
    return FirebaseDatabase.instance
        .reference()
        .child('original-images/$userId/$entryId')
        .update(<String, dynamic>{'delete': true});
  }
}
