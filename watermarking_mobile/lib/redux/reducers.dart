import 'package:redux/redux.dart';
import 'package:watermarking_mobile/models/app_state.dart';
import 'package:watermarking_mobile/models/detection_item.dart';
import 'package:watermarking_mobile/models/extracted_image_reference.dart';
import 'package:watermarking_mobile/models/file_upload.dart';
import 'package:watermarking_mobile/models/original_images_view_model.dart';
import 'package:watermarking_mobile/models/problem.dart';
import 'package:watermarking_mobile/models/user_model.dart';
import 'package:watermarking_mobile/redux/actions.dart';

/// Reducer
final Function appReducer = combineReducers<AppState>(<Reducer<AppState>>[
  TypedReducer<AppState, ActionSetAuthState>(_setAuthState),
  TypedReducer<AppState, ActionSetProfilePicUrl>(_setProfilePicUrl),
  TypedReducer<AppState, ActionSetOriginalImages>(_setOriginalImages),
  TypedReducer<AppState, ActionSetDetectionItems>(_setDetectionItems),
  TypedReducer<AppState, ActionSetBottomNav>(_setBottomNav),
  TypedReducer<AppState, ActionShowBottomSheet>(_setBottomSheet),
  TypedReducer<AppState, ActionSetSelectedImage>(_setSelectedImage),
  TypedReducer<AppState, ActionAddDetectionItem>(_addDetectionItem),
  TypedReducer<AppState, ActionStartUpload>(_setUploadStartTime),
  TypedReducer<AppState, ActionSetUploadProgress>(_setUploadProgress),
  TypedReducer<AppState, ActionSetUploadSuccess>(_setUploadSucceeded),
  TypedReducer<AppState, ActionSetDetectingProgress>(_setDetectingProgress),
  TypedReducer<AppState, ActionAddProblem>(_addProblem),
  TypedReducer<AppState, ActionRemoveProblem>(_removeProblem),
]);

// the uid is added by the firebase auth listener in the authStateChanged StreamBuilder
AppState _setAuthState(
        AppState state, ActionSetAuthState action) =>
    state.copyWith(
        user: UserModel(
            id: action.userId, photoUrl: action.photoUrl, waiting: false));

AppState _setProfilePicUrl(AppState state, ActionSetProfilePicUrl action) {
  final UserModel newUserModel = state.user.copyWith(photoUrl: action.url);
  return state.copyWith(user: newUserModel);
}

// any change to the original images list pushes the whole new list down the stream
AppState _setOriginalImages(AppState state, ActionSetOriginalImages action) {
  return state.copyWith(
      originals: OriginalImagesViewModel(images: action.images));
}

AppState _setBottomNav(AppState state, ActionSetBottomNav action) {
  return state.copyWith(
      bottomNav: state.bottomNav.copyWith(index: action.index));
}

AppState _setBottomSheet(AppState state, ActionShowBottomSheet action) {
  return state.copyWith(
      bottomNav: state.bottomNav.copyWith(shouldShowBottomSheet: action.show));
}

// any change to the profile pics list pushes the whole new list down the stream
AppState _setSelectedImage(AppState state, ActionSetSelectedImage action) {
  // create the next viewmodel for the images
  // TODO(nickm): when the image reference contains the size,
  // just use the selected image
  return state.copyWith(
      originals: state.originals.copyWith(
          selectedImage: action.image,
          selectedWidth: action.width,
          selectedHeight: action.height),
      bottomNav: state.bottomNav.copyWith(shouldShowBottomSheet: false));
}

// any change to the detection items list pushes the whole new list down the stream
AppState _setDetectionItems(AppState state, ActionSetDetectionItems action) {
  // update the viewmodel with the extracted images
  return state.copyWith(
      detections: state.detections.copyWith(items: action.items));
}

// Create a new DetectionItem with the given extracted image
AppState _addDetectionItem(AppState state, ActionAddDetectionItem action) {
  final ExtractedImageReference newRef = ExtractedImageReference(
      localPath: action.extractedPath, upload: FileUpload(bytesSent: 0));

  DetectionItem newItem = DetectionItem(
    id: action.id,
    extractedRef: newRef,
    originalRef: state.originals.selectedImage,
    started: DateTime.now(),
  );

  return state.copyWith(
      detections: state.detections
          .copyWith(items: [newItem, ...state.detections.items]));
}

AppState _setUploadStartTime(AppState state, ActionStartUpload action) {
  // find the relevant DetectionItem and set the start time of the upload
  final List<DetectionItem> nextItems = state.detections.items
      .map<DetectionItem>((DetectionItem item) => (item.id == action.id)
          ? item.copyWith(
              extractedRef: item.extractedRef.copyWith(
                  upload: item.extractedRef.upload
                      .copyWith(started: DateTime.now())))
          : item)
      .toList();

  // return the new state
  return state.copyWith(
      detections: state.detections.copyWith(items: nextItems));
}

AppState _setUploadProgress(AppState state, ActionSetUploadProgress action) {
  // find the relevant DetectionItem and set the progress of the upload
  final List<DetectionItem> nextItems = state.detections.items
      .map<DetectionItem>((DetectionItem item) => (item.id == action.id)
          ? item.copyWith(
              extractedRef: item.extractedRef.copyWith(
                  upload: item.extractedRef.upload.copyWith(
                      latestEvent: UploadingEvent.progress,
                      bytesSent: action.bytes)))
          : item)
      .toList();

  // return the new state
  return state.copyWith(
      detections: state.detections.copyWith(items: nextItems));
}

// when we receive a success event, change the relevant latestEvent property to success
AppState _setUploadSucceeded(AppState state, ActionSetUploadSuccess action) {
  // find the relevant DetectionItem and set the progress of the upload
  final List<DetectionItem> nextItems = state.detections.items
      .map<DetectionItem>((DetectionItem item) => (item.id == action.id)
          ? item.copyWith(
              extractedRef: item.extractedRef.copyWith(
                  upload: item.extractedRef.upload
                      .copyWith(latestEvent: UploadingEvent.success)))
          : item)
      .toList();

  // return the new state
  return state.copyWith(
      detections: state.detections.copyWith(items: nextItems));
}

// when we receive a progress event, add the change to the correct item
AppState _setDetectingProgress(
    AppState state, ActionSetDetectingProgress action) {
  // find the relevant DetectionItem and set the progress of the detection
  final List<DetectionItem> nextItems = state.detections.items
      .map<DetectionItem>((DetectionItem item) => (item.id == action.id)
          ? item.copyWith(progress: action.progress, result: action.result)
          : item)
      .toList();

  // return the new state
  return state.copyWith(
      detections: state.detections.copyWith(items: nextItems));
}

AppState _addProblem(AppState state, ActionAddProblem action) {
  // TODO(nickm): remove in production
  print(action.problem);

  // make new problems list with the new problem added
  final List<Problem> newProblems =
      List<Problem>.unmodifiable(state.problems + <Problem>[action.problem]);

  // if it was an upload problem, also edit the relevant FileUpload object
  if (action.problem.type == ProblemType.imageUpload) {
    // make new list of DetectionItems with new latest event for the upload
    final List<DetectionItem> nextItems = state.detections.items
        .map<DetectionItem>((DetectionItem item) =>
            (item.id == action.problem.info['id'])
                ? item.copyWith(
                    extractedRef: item.extractedRef.copyWith(
                        upload: item.extractedRef.upload
                            .copyWith(latestEvent: UploadingEvent.failure)))
                : item)
        .toList();

    return state.copyWith(
        problems: newProblems,
        detections: state.detections.copyWith(items: nextItems));
  } else {
    // otherwise just return the new state
    return state.copyWith(problems: newProblems);
  }
}

AppState _removeProblem(AppState state, ActionRemoveProblem action) {
  // remove the uploading item this action refers to
  final List<Problem> nextProblems = state.problems
      .where((Problem problem) => problem != action.problem)
      .toList();

  // return the new state
  return state.copyWith(problems: nextProblems);
}
