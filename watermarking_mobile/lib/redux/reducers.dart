import 'package:redux/redux.dart';
import 'package:watermarking_mobile/models/app_state.dart';
import 'package:watermarking_mobile/models/images_view_model.dart';
import 'package:watermarking_mobile/models/problem.dart';
import 'package:watermarking_mobile/models/upload_item.dart';
import 'package:watermarking_mobile/models/user_model.dart';
import 'package:watermarking_mobile/redux/actions.dart';

/// Reducer
final Function appReducer = combineReducers<AppState>(<Reducer<AppState>>[
  TypedReducer<AppState, ActionSetAuthState>(_setUserId),
  TypedReducer<AppState, ActionSetProfilePicUrl>(_setProfilePicUrl),
  TypedReducer<AppState, ActionSetImages>(_setImages),
  TypedReducer<AppState, ActionStartImageUpload>(_beginImageUpload),
  TypedReducer<AppState, ActionSetImageUploadProgress>(_setImageUploadProgress),
  // TypedReducer<AppState, ImageUploadPauseAction>(_pauseImageUpload),
  // TypedReducer<AppState, ImageUploadResumeAction>(_resumeImageUpload),
  TypedReducer<AppState, ActionSetImageUploadSuccess>(_setImageUploadSucceeded),
  TypedReducer<AppState, ActionRemoveUploadItem>(_removeUploadItem),
  TypedReducer<AppState, ActionAddProblem>(_addProblem),
]);

// the uid is added by the firebase auth listener in the authStateChanged StreamBuilder
AppState _setUserId(AppState state, ActionSetAuthState action) =>
    state.copyWith(user: UserModel(id: action.userId, waiting: false));

AppState _setProfilePicUrl(AppState state, ActionSetProfilePicUrl action) {
  final UserModel newUserModel = state.user.copyWith(photoUrl: action.url);
  return state.copyWith(user: newUserModel);
}

// any change to the profile pics list pushes the whole new list down the stream
AppState _setImages(AppState state, ActionSetImages action) {
  // set the UploadItem to processed if it refers to one of the images
  UploadItem newUpload =
      state.upload.copyWith(latestEvent: UploadingEvent.processed);

  // create the viewmodel for the images
  ImagesViewModel newImages = ImagesViewModel(images: action.images);

  return state.copyWith(images: newImages, upload: newUpload);
}

// When the detected image file is ready, the ActionStartImageUpload is dispatched
// with the file path and size. The file size is added to the UploadingState of the
// store while the path is added to the
AppState _beginImageUpload(AppState state, ActionStartImageUpload action) {
  // create the new upload item
  final UploadItem newUpload = UploadItem(
      id: action.id,
      filePath: action.filePath,
      latestEvent: UploadingEvent.started,
      bytesSent: 0,
      totalBytes: action.totalBytes,
      started: DateTime.now());

  return state.copyWith(upload: newUpload);
}

AppState _setImageUploadProgress(
    AppState state, ActionSetImageUploadProgress action) {
  // replace the uploading item this progress event refers to and return the new state
  return state.copyWith(
      upload: state.upload.copyWith(
          latestEvent: UploadingEvent.progress, bytesSent: action.bytes));
}

// AppState _pauseImageUpload(
//         AppState state, ImageUploadPauseAction action) =>
//     state.copyWith(
//         profileViewModel:
//             state.profileViewModel.copyWith(pickedPhotoPath: null));

// AppState _resumeImageUpload(
//         AppState state, ImageUploadResumeAction action) =>
//     state.copyWith(
//         profileViewModel:
//             state.profileViewModel.copyWith(pickedPhotoPath: null));

// when we receive a success event, change the relevant latestEvent property to success
AppState _setImageUploadSucceeded(
    AppState state, ActionSetImageUploadSuccess action) {
  // return the new state
  return state.copyWith(
      upload: state.upload.copyWith(latestEvent: UploadingEvent.success));
}

// as we only have one upload item, just set to processed
// TODO(nickm): review if we need remove functionality
AppState _removeUploadItem(AppState state, ActionRemoveUploadItem action) {
  // remove the uploading item this action refers to return the new state
  return state.copyWith(
      upload: state.upload.copyWith(latestEvent: UploadingEvent.processed));
}

AppState _addProblem(AppState state, ActionAddProblem action) {
  // add to the list of problems
  final List<Problem> newProblems =
      List<Problem>.unmodifiable(state.problems + <Problem>[action.problem]);

  // if it was an upload problem, also edit the relevant UploadItem
  if (action.problem.type == ProblemType.imageUpload) {
    // update the uploading item this problem refers to
    return state.copyWith(
        problems: newProblems,
        upload: state.upload.copyWith(latestEvent: UploadingEvent.failure));
  } else {
    // otherwise just return the new state
    return state.copyWith(problems: newProblems);
  }
}
