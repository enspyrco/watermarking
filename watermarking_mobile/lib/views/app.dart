import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:redux/redux.dart';
import 'package:watermarking_mobile/models/app_state.dart';
import 'package:watermarking_mobile/models/problem.dart';
import 'package:watermarking_mobile/models/user_model.dart';
import 'package:watermarking_mobile/redux/actions.dart';
import 'package:watermarking_mobile/views/account_button.dart';
import 'package:watermarking_mobile/views/home_page.dart';
import 'package:watermarking_mobile/views/signin_page.dart';

class MyApp extends StatelessWidget {
  MyApp(this.store, {Key key}) : super(key: key);

  final Store<AppState> store;

  @override
  Widget build(BuildContext context) {
    store.dispatch(const ActionObserveAuthState());
    return StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
            home: StoreConnector<AppState, UserModel>(
                converter: (Store<AppState> store) => store.state.user,
                builder: (BuildContext context, UserModel user) {
                  if (user.waiting) {
                    return const Text('Waiting',
                        textDirection: TextDirection.ltr);
                  }
                  if (user.id != null) {
                    return const AppWidget();
                  }
                  return SigninPage();
                })));
  }
}

class AppWidget extends StatefulWidget {
  const AppWidget({Key key}) : super(key: key);

  @override
  _AppWidgetState createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  static const platform = const MethodChannel('watermarking.enspyr.co/detect');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SvgPicture.asset(
          'assets/dw_logo_white.svg',
          height: 100.0,
          fit: BoxFit.cover,
          allowDrawingOutsideViewBox: true,
        ),
        actions: <Widget>[
          AccountButton(key: const Key('AccountButton')),
          StoreConnector<AppState, List<Problem>>(
            distinct: true,
            converter: (Store<AppState> store) => store.state.problems,
            builder: (BuildContext context, List<Problem> problems) {
              final int numProblems = problems.length;
              return (numProblems == 0)
                  ? Container(width: 0.0, height: 0.0)
                  : MaterialButton(
                      child: Text(numProblems.toString()),
                      onPressed: () => _display(context, problems.last.message),
                    );
            },
          )
        ],
      ),
      body: const HomePage(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => platform.invokeMethod('startDetection'),
        tooltip: 'Scan',
        child: Icon(Icons.search),
      ),
    );
  }

  Future<void> _display(BuildContext context, String errorMessage) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Whoops!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('There was a problem.'),
                Text(errorMessage),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
