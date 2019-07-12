import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:redux_dev_tools/redux_dev_tools.dart';
import 'package:redux_remote_devtools/redux_remote_devtools.dart';
import 'package:watermarking_mobile/models/app_state.dart';
import 'package:watermarking_mobile/redux/epics.dart';
import 'package:watermarking_mobile/redux/middleware.dart';
import 'package:watermarking_mobile/redux/reducers.dart';
import 'package:watermarking_mobile/services/auth_service.dart';
import 'package:watermarking_mobile/services/database_service.dart';
import 'package:watermarking_mobile/services/device_service.dart';
import 'package:watermarking_mobile/services/storage_service.dart';
import 'package:watermarking_mobile/views/app.dart';

Future<void> main() async {
  final RemoteDevToolsMiddleware remoteDevtools =
      RemoteDevToolsMiddleware('172.20.10.10:8000');
  await remoteDevtools.connect();

  final AuthService authService = AuthService();
  final DatabaseService databaseService = DatabaseService();
  final StorageService storageService = StorageService();
  final DeviceService deviceService = DeviceService();

  // use the DevToolsStore to take advantage of time travel
  final DevToolsStore<AppState> store = DevToolsStore<AppState>(appReducer,
      middleware: <Middleware<AppState>>[
        remoteDevtools,
        ...createMiddlewares(
            authService, databaseService, deviceService, storageService),
        createEpicMiddleware(authService, databaseService, storageService),
      ],
      initialState: AppState.intialState());

  remoteDevtools.store = store;

  runApp(MyApp(store));
}
