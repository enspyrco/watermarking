import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:meta/meta.dart';
import 'package:watermarking_mobile/models/problem.dart';
import 'package:watermarking_mobile/redux/actions.dart';

class StorageService {
  StorageService();

  String userId;
  Map<String, StorageUploadTask> uploadTasks = <String, StorageUploadTask>{};

  // error codes that can come from firebase storage plugin
  // mapped to a string for display
  static final Map<int, String> errorCodeStrings = <int, String>{
    StorageError.unknown: 'StorageError.unknown',
    StorageError.objectNotFound: 'StorageError.objectNotFound',
    StorageError.bucketNotFound: 'StorageError.bucketNotFound',
    StorageError.projectNotFound: 'StorageError.projectNotFound',
    StorageError.quotaExceeded: 'StorageError.quotaExceeded',
    StorageError.notAuthenticated: 'StorageError.notAuthenticated',
    StorageError.notAuthorized: 'StorageError.notAuthorized',
    StorageError.retryLimitExceeded: 'StorageError.retryLimitExceeded',
    StorageError.invalidChecksum: 'StorageError.invalidChecksum',
    StorageError.canceled: 'StorageError.canceled',
  };

  /// Start an upload and return a stream that emits actions of type:
  /// - ActionProfilePicUploadSuccess
  /// - ActionProfilePicUploadFailure
  /// - ActionProfilePicUploadProgress
  /// - ActionProfilePicUploadPause
  /// - ActionProfilePicUploadResume
  ///
  /// [uid] is the user ID
  /// [photoPath] is the path to the photo to upload
  ///
  Stream<dynamic> startUpload(
      {@required String photoPath, @required String entryId}) {
    // access the file
    final File picFile = File(photoPath);

    // setup an upload task and initiate the upload
    final FirebaseStorage storage = FirebaseStorage();
    final StorageReference ref = storage
        .ref()
        .child('detecting-images')
        .child('$userId')
        .child('$entryId');
    final StorageUploadTask uploadTask = ref.putFile(
      picFile,
      StorageMetadata(
        contentType: 'image/.',
        customMetadata: <String, String>{'docId': entryId, 'uid': userId},
      ),
    );

    // keep the upload task in case we want to cancel
    uploadTasks[entryId] = uploadTask;

    // return the upload task's event stream, transformed to actions
    return uploadTask.events.map<dynamic>((StorageTaskEvent event) {
      final String metadataEntryId =
          event.snapshot.storageMetadata.customMetadata['docId'];
      switch (event.type) {
        case StorageTaskEventType.success:
          return ActionSetUploadSuccess(id: metadataEntryId);
        case StorageTaskEventType.failure:
          return ActionAddProblem(
              problem: Problem(
                  type: ProblemType.imageUpload,
                  message: errorCodeStrings[event.snapshot.error],
                  info: <String, dynamic>{
                'errorCode': event.snapshot.error,
                'itemId': metadataEntryId
              }));
        case StorageTaskEventType.progress:
          return ActionSetUploadProgress(
              bytes: event.snapshot.bytesTransferred, id: metadataEntryId);
        case StorageTaskEventType.pause:
          return ActionSetUploadPaused(id: metadataEntryId);
        case StorageTaskEventType.resume:
          return ActionSetUploadResumed(id: metadataEntryId);
      }
    });
  }

  void cancelUpload(String entryId) {
    uploadTasks[entryId].cancel();
  }

  void pauseUpload(String entryId) {
    uploadTasks[entryId].pause();
  }

  void resumeUpload(String entryId) {
    uploadTasks[entryId].resume();
  }
}
