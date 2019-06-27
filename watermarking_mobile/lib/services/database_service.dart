import 'dart:async';

class DatabaseService {
  DatabaseService();

  String userId;
  StreamSubscription<dynamic> profilePicUrlSubscription;
  StreamSubscription<dynamic> profilePicsSubscription;

  // create a document id that will be added as metadata to the upload
  // for use in a cloud function
  String getProfilePicEntryId() => Firestore.instance
      .collection('users/$userId/profilePics')
      .document()
      .documentID;

  Stream<dynamic> connectToProfilePicUrl() {
    return Firestore.instance
        .document('users/$userId')
        .snapshots()
        .map<dynamic>((DocumentSnapshot snapshot) =>
            ActionSetProfilePicUrl(url: snapshot.data['photoURL']))
        .handleError((dynamic error) => ActionAddProblem(
            problem: Problem(
                type: ProblemType.profilePicUrl, message: error.toString())));
  }

  Future<dynamic> cancelProfilePicUrlSubscription() {
    if (profilePicUrlSubscription == null) {
      return Future<dynamic>.value(null);
    }
    return profilePicUrlSubscription.cancel();
  }

  Stream<dynamic> connectToProfilePics() {
    return Firestore.instance
        .collection('users/$userId/profilePics')
        .snapshots()
        .map<dynamic>((QuerySnapshot snapshot) => ActionSetProfilePics(
            pics: snapshot.documents
                .map<ProfilePic>((DocumentSnapshot document) => ProfilePic(
                    id: document.documentID,
                    url: document.data['servingUrl'],
                    deleting: document.data['delete']))
                .toList()))
        .handleError((dynamic error) => ActionAddProblem(
            problem: Problem(
                type: ProblemType.profilePics, message: error.toString())));
  }

  Future<dynamic> cancelProfilePicsSubscription() {
    if (profilePicsSubscription == null) {
      return Future<dynamic>.value(null);
    }
    return profilePicsSubscription.cancel();
  }

  /// Adds a flag to the profilePic entry that will be picked up by a cloud
  /// function and go through the deletion sequence (remove file, stop serving)
  Future<void> requestProfilePicDelete(String entryId) {
    return Firestore.instance
        .document('users/$userId/profilePics/$entryId')
        .updateData(<String, dynamic>{'delete': true});
  }
}
