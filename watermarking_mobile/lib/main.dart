import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:watermarking_mobile/models/app_state.dart';
import 'package:watermarking_mobile/redux/epics.dart';
import 'package:watermarking_mobile/redux/middleware.dart';
import 'package:watermarking_mobile/redux/reducers.dart';
import 'package:watermarking_mobile/services/auth_service.dart';
import 'package:watermarking_mobile/services/database_service.dart';
import 'package:watermarking_mobile/services/device_service.dart';
import 'package:watermarking_mobile/services/storage_service.dart';
import 'package:watermarking_mobile/views/app.dart';

void main() {
  final AuthService authService = AuthService();
  final DatabaseService databaseService = DatabaseService();
  final StorageService storageService = StorageService();
  final DeviceService deviceService = DeviceService();

  final Store<AppState> store = Store<AppState>(appReducer,
      middleware: <Middleware<AppState>>[
        ...createMiddlewares(
            authService, databaseService, deviceService, storageService),
        createEpicMiddleware(authService, databaseService, storageService),
      ],
      initialState: AppState.intialState());

  runApp(MyApp(store));
}
