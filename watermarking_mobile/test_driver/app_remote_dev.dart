import 'package:flutter/widgets.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:redux_remote_devtools/redux_remote_devtools.dart';

import 'package:watermarking_mobile/models/app_state.dart';
import 'package:watermarking_mobile/redux/epics.dart';
import 'package:watermarking_mobile/redux/middleware.dart';
import 'package:watermarking_mobile/redux/reducers.dart';
import 'package:watermarking_mobile/views/app.dart';

import 'mock_auth_service.dart';
import 'mock_database.dart';
import 'mock_database_service.dart';
import 'mock_device_service.dart';
import 'mock_storage_service.dart';

class MockClient extends Mock implements http.Client {}

Future<void> main() async {
  enableFlutterDriverExtension();

  final RemoteDevToolsMiddleware remoteDevtools =
      RemoteDevToolsMiddleware('172.20.10.10:8000');
  await remoteDevtools.connect();

  final MockDatabase database = MockDatabase();
  final MockAuthService authService = MockAuthService();
  final MockDatabaseService databaseService = MockDatabaseService(database);
  final MockStorageService storageService = MockStorageService(database);
  final MockDeviceService deviceService = MockDeviceService();

  final Store<AppState> store = Store<AppState>(appReducer,
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
