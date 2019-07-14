import 'package:redux/redux.dart';
import 'package:watermarking_mobile/models/app_state.dart';
import 'package:watermarking_mobile/models/problem.dart';
import 'package:watermarking_mobile/redux/actions.dart';
import 'package:watermarking_mobile/services/auth_service.dart';
import 'package:watermarking_mobile/services/database_service.dart';
import 'package:watermarking_mobile/services/device_service.dart';
import 'package:watermarking_mobile/services/storage_service.dart';

// A middleware takes in 3 parameters: your Store, which you can use to
// read state or dispatch new actions, the action that was dispatched,
// and a `next` function. The first two you know about, and the `next`
// function is responsible for sending the action to your Reducer, or
// the next Middleware if you provide more than one.
//
// Middleware do not return any values themselves. They simply forward
// actions on to the Reducer or swallow actions in some special cases.

// NextDispatcher sends the action to the Reducer, or
// the next Middleware if we provide more than one.
// Middleware do not return any values themselves. They simply forward
// actions on to the Reducer or swallow actions in some special cases.

List<Middleware<AppState>> createMiddlewares(
    AuthService authService,
    DatabaseService databaseService,
    DeviceService deviceService,
    StorageService storageService) {
  return <Middleware<AppState>>[
    TypedMiddleware<AppState, ActionSignout>(
      _signOut(authService),
    ),
    TypedMiddleware<AppState, ActionSetAuthState>(
      _saveAuthStateAndObserveProfile(databaseService, storageService),
    ),
    TypedMiddleware<AppState, ActionPerformExtraction>(
      _performExtraction(deviceService),
    ),
    TypedMiddleware<AppState, ActionProcessExtraction>(
      _processExtraction(databaseService, deviceService),
    ),
    TypedMiddleware<AppState, ActionSetUploadSuccess>(
      _startWatermarkDetection(databaseService),
    ),
    TypedMiddleware<AppState, ActionCancelUpload>(
      _cancelUpload(databaseService, storageService),
    ),
  ];
}

void Function(Store<AppState> store, ActionSignout action, NextDispatcher next)
    _signOut(AuthService authService) {
  return (Store<AppState> store, ActionSignout action,
      NextDispatcher next) async {
    next(action);

    // attempt to sign out and dispatch appropiate actions based on result
    try {
      await authService.signOut();
    } catch (error) {
      store.dispatch(ActionAddProblem(
          problem:
              Problem(type: ProblemType.signout, message: error.toString())));
    }
  };
}

/// AuthState changes when a user signs in or out
/// The [AuthStateChangedAction] contains a single member, uid
/// which will be either null or a valid uid
void Function(
        Store<AppState> store, ActionSetAuthState action, NextDispatcher next)
    _saveAuthStateAndObserveProfile(
  DatabaseService databaseService,
  StorageService storageService,
) {
  return (Store<AppState> store, ActionSetAuthState action,
      NextDispatcher next) {
    // set/reset the userId store in services before dispatching next action
    databaseService.userId = action.userId;
    storageService.userId = action.userId;
    next(action);

    // cancel any previous subscription
    databaseService.profileSubscription?.cancel();
    databaseService.originalsSubscription?.cancel();
    databaseService.detectionSubscription?.cancel();

    if (action.userId == null) return;

    databaseService.profileSubscription = databaseService
        .connectToProfile()
        .listen(
            (dynamic action) => store.dispatch(action),
            onError: (dynamic error) => store.dispatch(ActionAddProblem(
                problem: Problem(
                    type: ProblemType.profile, message: error.toString()))),
            cancelOnError: true);

    databaseService.originalsSubscription = databaseService
        .connectToOriginals()
        .listen((dynamic action) => store.dispatch(action),
            onError: (dynamic error) => store.dispatch(ActionAddProblem(
                problem: Problem(
                    type: ProblemType.images, message: error.toString()))),
            cancelOnError: true);

    databaseService.detectionSubscription = databaseService
        .connectToDetection()
        .listen((dynamic action) => store.dispatch(action),
            onError: (dynamic error) => store.dispatch(ActionAddProblem(
                problem: Problem(
                    type: ProblemType.images, message: error.toString()))),
            cancelOnError: true);
  };
}

/// Intercept [ActionPerformExtraction] and use [DeviceService] to ...
void Function(Store<AppState> store, ActionPerformExtraction action,
    NextDispatcher next) _performExtraction(
  DeviceService deviceService,
) {
  return (Store<AppState> store, ActionPerformExtraction action,
      NextDispatcher next) async {
    next(action);

    final List<String> paths = await deviceService.performExtraction(
        width: action.width, height: action.height);

    store.dispatch(ActionProcessExtraction(filePaths: paths));
  };
}

/// Intercept [ActionProcessExtractedImage] and use [DatabaseService] to generate a
/// unique id then dispatch [ActionStartImageUpload]
void Function(Store<AppState> store, ActionProcessExtraction action,
        NextDispatcher next)
    _processExtraction(
        DatabaseService databaseService, DeviceService deviceService) {
  return (Store<AppState> store, ActionProcessExtraction action,
      NextDispatcher next) async {
    next(action);

    for (String path in action.filePaths) {
      final String newId = databaseService.getDetectedImageEntryId();
      final int bytes = await deviceService.findFileSize(path: path);
      store.dispatch(
          ActionAddDetectionItem(id: newId, extractedPath: path, bytes: bytes));
      store.dispatch(ActionStartUpload(id: newId, filePath: path));
    }
  };
}

/// Intercept [ActionSetUploadSuccess] and use [DatabaseService] to add
/// an entry in the database that the server is observing
void Function(Store<AppState> store, ActionSetUploadSuccess action,
    NextDispatcher next) _startWatermarkDetection(
  DatabaseService databaseService,
) {
  return (Store<AppState> store, ActionSetUploadSuccess action,
      NextDispatcher next) {
    next(action);
    try {
      databaseService.addDetectionEntry(
          store.state.originals.selectedImage.filePath,
          'detecting-images/${store.state.user.id}/${action.id}');
    } catch (exception) {
      print(exception);
    }
  };
}

void Function(
        Store<AppState> store, ActionCancelUpload action, NextDispatcher next)
    _cancelUpload(
        DatabaseService databaseService, StorageService storageService) {
  return (Store<AppState> store, ActionCancelUpload action,
      NextDispatcher next) {
    next(action);
    storageService.cancelUpload(action.id);
  };
}
