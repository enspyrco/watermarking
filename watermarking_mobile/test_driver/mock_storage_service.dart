import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:watermarking_mobile/redux/actions.dart';
import 'package:watermarking_mobile/services/storage_service.dart';

import 'mock_database.dart';

/// The [MockDatabase] object is part of the [MockDatabaseService] and is used to
/// simulate events such as cloud functions adding to the real database
class MockStorageService implements StorageService {
  MockStorageService(this.database);
  final MockDatabase database;

  @override
  String userId;

  @override
  Stream<dynamic> startUpload({String filePath, String entryId}) async* {
    double percent = 0;
    while (percent < 0.6) {
      await Future<void>.delayed(Duration(milliseconds: 500));
      percent += 0.2;
      yield ActionSetUploadProgress(
          id: entryId, bytes: (percent * 100).round());
    }

    // yield const ActionAddProblem(
    //     problem: Problem(
    //         type: ProblemType.profilePicUpload,
    //         message: 'hello!',
    //         info: <String, dynamic>{'itemId': '1', 'errorCode': -13013}));

    // yield const ActionSetProfilePicUploadSuccess(id: '1');

    // await Future<void>.delayed(Duration(milliseconds: 2000));
    // database
    //     .addProfilePic(const ProfilePic(id: '1', deleting: false, url: 'test'));
  }

  @override
  Map<String, StorageUploadTask> uploadTasks;

  @override
  void cancelUpload(String entryId) {
    // TODO: implement cancelUpload
  }

  @override
  void pauseUpload(String entryId) {
    // TODO: implement pauseUpload
  }

  @override
  void resumeUpload(String entryId) {
    // TODO: implement resumeUpload
  }
}
