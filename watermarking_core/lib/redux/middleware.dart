import 'package:redux/redux.dart';
import 'package:watermarking_core/models/app_state.dart';
import 'package:watermarking_core/models/problem.dart';
import 'package:watermarking_core/redux/actions.dart';
import 'package:watermarking_core/services/auth_service.dart';
import 'package:watermarking_core/services/database_service.dart';
import 'package:watermarking_core/services/device_service.dart';
import 'package:watermarking_core/services/storage_service.dart';

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
      _setUserAndObserveDatabase(databaseService, storageService),
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
      _cancelUpload(storageService),
    ),
  ];
}

void Function(Store<AppState> store, ActionSignout action, NextDispatcher next)
    _signOut(AuthService authService) {
  return (Store<AppState> store, ActionSignout action,
      NextDispatcher next) async {
    next(action);

    try {
      await authService.signOut();
    } catch (error) {
      store.dispatch(ActionAddProblem(
          problem:
              Problem(type: ProblemType.signout, message: error.toString())));
    }
  };
}

void Function(
        Store<AppState> store, ActionSetAuthState action, NextDispatcher next)
    _setUserAndObserveDatabase(
  DatabaseService databaseService,
  StorageService storageService,
) {
  return (Store<AppState> store, ActionSetAuthState action,
      NextDispatcher next) {
    databaseService.userId = action.userId;
    storageService.userId = action.userId;
    next(action);

    databaseService.profileSubscription?.cancel();
    databaseService.originalsSubscription?.cancel();
    databaseService.detectingSubscription?.cancel();
    databaseService.detectionItemsSubscription?.cancel();

    if (action.userId == null) return;

    databaseService.profileSubscription = databaseService
        .connectToProfile()
        .listen((dynamic action) => store.dispatch(action),
            onError: (Object error, StackTrace trace) => store.dispatch(
                  ActionAddProblem(
                    problem: Problem(
                      type: ProblemType.profile,
                      message: error.toString(),
                      trace: trace,
                    ),
                  ),
                ),
            cancelOnError: true);

    databaseService.originalsSubscription = databaseService
        .connectToOriginals()
        .listen((dynamic action) => store.dispatch(action),
            onError: (Object error, StackTrace trace) => store.dispatch(
                  ActionAddProblem(
                    problem: Problem(
                      type: ProblemType.images,
                      message: error.toString(),
                      trace: trace,
                    ),
                  ),
                ),
            cancelOnError: true);

    databaseService.detectionItemsSubscription = databaseService
        .connectToDetectionItems()
        .listen((dynamic action) => store.dispatch(action),
            onError: (Object error, StackTrace trace) => store.dispatch(
                  ActionAddProblem(
                    problem: Problem(
                      type: ProblemType.images,
                      message: error.toString(),
                      trace: trace,
                    ),
                  ),
                ),
            cancelOnError: true);

    databaseService.detectingSubscription = databaseService
        .connectToDetecting()
        .listen((dynamic action) => store.dispatch(action),
            onError: (Object error, StackTrace trace) => store.dispatch(
                  ActionAddProblem(
                    problem: Problem(
                      type: ProblemType.images,
                      message: error.toString(),
                      trace: trace,
                    ),
                  ),
                ),
            cancelOnError: true);
  };
}

void Function(Store<AppState> store, ActionPerformExtraction action,
    NextDispatcher next) _performExtraction(
  DeviceService deviceService,
) {
  return (Store<AppState> store, ActionPerformExtraction action,
      NextDispatcher next) async {
    next(action);

    final String path = await deviceService.performExtraction(
        width: action.width, height: action.height);

    store.dispatch(ActionProcessExtraction(filePath: path));
  };
}

void Function(Store<AppState> store, ActionProcessExtraction action,
        NextDispatcher next)
    _processExtraction(
        DatabaseService databaseService, DeviceService deviceService) {
  return (Store<AppState> store, ActionProcessExtraction action,
      NextDispatcher next) async {
    next(action);

    final String newId = databaseService.getDetectionItemId();
    final int bytes = await deviceService.findFileSize(path: action.filePath);
    store.dispatch(ActionAddDetectionItem(
        id: newId, extractedPath: action.filePath, bytes: bytes));
    store.dispatch(ActionStartUpload(id: newId, filePath: action.filePath));
  };
}

void Function(Store<AppState> store, ActionSetUploadSuccess action,
    NextDispatcher next) _startWatermarkDetection(
  DatabaseService databaseService,
) {
  return (Store<AppState> store, ActionSetUploadSuccess action,
      NextDispatcher next) {
    next(action);
    try {
      final selectedImagePath = store.state.originals.selectedImage?.filePath;
      if (selectedImagePath != null) {
        databaseService.addDetectingEntry(
            itemId: action.id,
            originalPath: selectedImagePath,
            markedPath: 'detecting-images/${store.state.user.id}/${action.id}');
      }
    } catch (exception) {
      // ignore: avoid_print
      print(exception);
    }
  };
}

void Function(
        Store<AppState> store, ActionCancelUpload action, NextDispatcher next)
    _cancelUpload(StorageService storageService) {
  return (Store<AppState> store, ActionCancelUpload action,
      NextDispatcher next) {
    next(action);
    storageService.cancelUpload(action.id);
  };
}
