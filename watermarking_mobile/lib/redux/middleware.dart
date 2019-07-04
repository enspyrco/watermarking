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
    TypedMiddleware<AppState, ActionSetDetectedImage>(
      _startUpload(databaseService),
    ),
    TypedMiddleware<AppState, ActionSetImageUploadSuccess>(
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
    databaseService.imagesSubscription?.cancel();

    if (action.userId != null) {
      databaseService.profileSubscription = databaseService
          .connectToProfile()
          .listen((dynamic action) => store.dispatch(action),
              onError: (dynamic error) => store.dispatch(ActionAddProblem(
                  problem: Problem(
                      type: ProblemType.profile, message: error.toString()))),
              cancelOnError: true);
    }

    if (action.userId != null) {
      databaseService.imagesSubscription = databaseService
          .connectToImages()
          .listen(
              (dynamic action) => store.dispatch(action),
              onError: (dynamic error) => store.dispatch(ActionAddProblem(
                  problem: Problem(
                      type: ProblemType.images, message: error.toString()))),
              cancelOnError: true);
    }
  };
}

/// Intercept [ActionSetDetectedImage] and use [DatabaseService] to generate a
/// unique id then dispatch [ActionStartUpload]
void Function(Store<AppState> store, ActionSetDetectedImage action,
    NextDispatcher next) _startUpload(
  DatabaseService databaseService,
) {
  return (Store<AppState> store, ActionSetDetectedImage action,
      NextDispatcher next) {
    next(action);

    store.dispatch(ActionStartImageUpload(
        id: databaseService.getDetectedImageEntryId(),
        filePath: action.filePath,
        totalBytes: null));
  };
}

/// Intercept [ActionSetImageUploadSuccess] and use [DatabaseService] to add
/// an entry in the database that the server observe
void Function(Store<AppState> store, ActionSetImageUploadSuccess action,
    NextDispatcher next) _startWatermarkDetection(
  DatabaseService databaseService,
) {
  return (Store<AppState> store, ActionSetImageUploadSuccess action,
      NextDispatcher next) {
    next(action);
    try {
      databaseService.addWatermarkDetectionEntry(
          store.state.images.selectedImage.filePath,
          // TODO(nickm): the marked image remote path should not be built from
          // the store state, maybe carried with the action?
          'detecting-images/${store.state.user.id}/${store.state.upload.id}');
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
