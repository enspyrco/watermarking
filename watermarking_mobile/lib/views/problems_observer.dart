import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:watermarking_mobile/models/app_state.dart';
import 'package:watermarking_mobile/models/problem.dart';
import 'package:watermarking_mobile/redux/actions.dart';

class ProblemsObserver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<Problem>>(
      distinct: true,
      converter: (Store<AppState> store) => store.state.problems,
      builder: (BuildContext context, List<Problem> problems) {
        final int numProblems = problems.length;
        if (numProblems > 0) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _display(context, problems.last));
        }

        return (numProblems == 0)
            ? Container(width: 0.0, height: 0.0)
            : MaterialButton(
                child: Text(numProblems.toString()),
                onPressed: () => {},
              );
      },
    );
  }

  Future<void> _display(BuildContext context, Problem problem) async {
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
                Text(problem.message),
                if (problem.trace != null) Text(problem.trace.toString()),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text('OK'),
              onPressed: () {
                StoreProvider.of<AppState>(context)
                    .dispatch(ActionRemoveProblem(problem: problem));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
