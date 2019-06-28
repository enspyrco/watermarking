import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:watermarking_mobile/models/problem.dart';
import 'package:watermarking_mobile/redux/actions.dart';

class DatabaseService {
  DatabaseService();

  String userId;
  StreamSubscription<dynamic> imagesSubscription;
  StreamSubscription<dynamic> profileSubscription;

  Stream<dynamic> connectToImages() {
    return FirebaseDatabase.instance
        .reference()
        .child('original-images/$userId')
        .onValue
        .map<dynamic>(
            (Event event) => ActionSetImages(images: event.snapshot.value))
        .handleError((dynamic error) => ActionAddProblem(
            problem:
                Problem(type: ProblemType.images, message: error.toString())));
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
            email: event.snapshot.value['email']))
        .handleError((dynamic error) => ActionAddProblem(
            problem:
                Problem(type: ProblemType.profile, message: error.toString())));
  }

  Future<dynamic> cancelProfileSubscription() {
    return (profileSubscription == null)
        ? Future<dynamic>.value(null)
        : profileSubscription.cancel();
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
