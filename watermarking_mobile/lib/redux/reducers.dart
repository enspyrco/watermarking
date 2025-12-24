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
final Reducer<AppState> appReducer = combineReducers<AppState>(<Reducer<AppState>>[
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

AppState _setAuthState(AppState state, ActionSetAuthState action) =>
    state.copyWith(
        user: UserModel(
            id: action.userId, photoUrl: action.photoUrl, waiting: false));

AppState _setProfilePicUrl(AppState state, ActionSetProfilePicUrl action) {
  final UserModel newUserModel = state.user.copyWith(photoUrl: action.url);
  return state.copyWith(user: newUserModel);
}

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

AppState _setSelectedImage(AppState state, ActionSetSelectedImage action) {
  return state.copyWith(
      originals: state.originals.copyWith(
          selectedImage: action.image,
          selectedWidth: action.width,
          selectedHeight: action.height),
      bottomNav: state.bottomNav.copyWith(shouldShowBottomSheet: false));
}

AppState _setDetectionItems(AppState state, ActionSetDetectionItems action) {
  return state.copyWith(
      detections: state.detections.copyWith(items: action.items));
}

AppState _addDetectionItem(AppState state, ActionAddDetectionItem action) {
  final ExtractedImageReference newRef = ExtractedImageReference(
      bytes: action.bytes,
      localPath: action.extractedPath,
      upload: const FileUpload(bytesSent: 0, percent: 0));

  final DetectionItem newItem = DetectionItem(
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
  final List<DetectionItem> nextItems = state.detections.items
      .map<DetectionItem>((DetectionItem item) => (item.id == action.id)
          ? item.copyWith(
              extractedRef: item.extractedRef?.copyWith(
                  upload: item.extractedRef?.upload
                      ?.copyWith(started: DateTime.now())))
          : item)
      .toList();

  return state.copyWith(
      detections: state.detections.copyWith(items: nextItems));
}

AppState _setUploadProgress(AppState state, ActionSetUploadProgress action) {
  final List<DetectionItem> nextItems = state.detections.items
      .map<DetectionItem>((DetectionItem item) {
    if (item.id != action.id) return item;
    final totalBytes = item.extractedRef?.bytes ?? 1;
    return item.copyWith(
      extractedRef: item.extractedRef?.copyWith(
        upload: item.extractedRef?.upload?.copyWith(
            latestEvent: UploadingEvent.progress,
            bytesSent: action.bytes,
            percent: action.bytes / totalBytes),
      ),
    );
  }).toList();

  return state.copyWith(
      detections: state.detections.copyWith(items: nextItems));
}

AppState _setUploadSucceeded(AppState state, ActionSetUploadSuccess action) {
  final List<DetectionItem> nextItems = state.detections.items
      .map<DetectionItem>((DetectionItem item) => (item.id == action.id)
          ? item.copyWith(
              extractedRef: item.extractedRef?.copyWith(
                  upload: item.extractedRef?.upload
                      ?.copyWith(latestEvent: UploadingEvent.success)))
          : item)
      .toList();

  return state.copyWith(
      detections: state.detections.copyWith(items: nextItems));
}

AppState _setDetectingProgress(
    AppState state, ActionSetDetectingProgress action) {
  final List<DetectionItem> nextItems = state.detections.items
      .map<DetectionItem>((DetectionItem item) => (item.id == action.id)
          ? item.copyWith(progress: action.progress, result: action.result)
          : item)
      .toList();

  return state.copyWith(
      detections: state.detections.copyWith(items: nextItems));
}

AppState _addProblem(AppState state, ActionAddProblem action) {
  // ignore: avoid_print
  print(action.problem);

  final List<Problem> newProblems =
      List<Problem>.unmodifiable([...state.problems, action.problem]);

  if (action.problem.type == ProblemType.imageUpload) {
    final problemId = action.problem.info?['id'];
    final List<DetectionItem> nextItems = state.detections.items
        .map<DetectionItem>((DetectionItem item) => (item.id == problemId)
            ? item.copyWith(
                extractedRef: item.extractedRef?.copyWith(
                    upload: item.extractedRef?.upload
                        ?.copyWith(latestEvent: UploadingEvent.failure)))
            : item)
        .toList();

    return state.copyWith(
        problems: newProblems,
        detections: state.detections.copyWith(items: nextItems));
  } else {
    return state.copyWith(problems: newProblems);
  }
}

AppState _removeProblem(AppState state, ActionRemoveProblem action) {
  final List<Problem> nextProblems = state.problems
      .where((Problem problem) => problem != action.problem)
      .toList();

  return state.copyWith(problems: nextProblems);
}
