import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:watermarking_mobile/models/app_state.dart';
import 'package:watermarking_mobile/models/detection_item.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        DetectionSteps(),
        Expanded(
          child: DetectionHistoryListView(),
        )
      ],
    );
  }
}

class DetectionHistoryListView extends StatelessWidget {
  const DetectionHistoryListView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<DetectionItem>>(
        converter: (Store<AppState> store) => store.state.detections.items,
        builder: (BuildContext context, List<DetectionItem> items) {
          return ListView.builder(
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                return Center(
                  child: Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          leading: Image.network(items[index].originalRef.url),
                          title: Text(items[index].progress ?? ''),
                          subtitle: Text(items[index].result ?? ''),
                        ),
                        LinearProgressIndicator(
                            value: items[index].extractedRef.upload.percent),
                        ListTile(
                          leading: Image.file(
                              File(items[index].extractedRef.localPath)),
                        ),
                      ],
                    ),
                  ),
                );
              });
        });
  }
}

class DetectionSteps extends StatelessWidget {
  const DetectionSteps({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 5),
      height: 90,
      child: Theme(
        data: ThemeData(
          primaryColor: Colors.red,
        ),
        child: Stepper(
          currentStep: 1,
          type: StepperType.horizontal,
          controlsBuilder: (BuildContext context,
              {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
            return Container();
          },
          steps: [
            Step(title: Text('Step1'), content: Container()),
            Step(
                title: Text('Step2'),
                content: Container(),
                state: StepState.indexed,
                isActive: true),
            Step(title: Text('Step3'), content: Container()),
          ],
          onStepTapped: print,
        ),
      ),
    );
  }
}
