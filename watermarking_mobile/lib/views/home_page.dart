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
    return DetectionHistoryListView();
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
          return Column(
            children: <Widget>[
              if (items.isNotEmpty && items.first.result == null)
                DetectionSteps(items.first),
              Expanded(
                child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Center(
                        child: Card(
                          color: (items[index].result == null)
                              ? Colors.blueGrey
                              : Colors.white,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                leading:
                                    Image.network(items[index].originalRef.url),
                                title: Text(items[index].result ?? ''),
                                subtitle: Text(
                                  items[index]
                                      .extractedRef
                                      .upload
                                      .started
                                      .toIso8601String(),
                                ),
                                trailing: Image.file(
                                  File(items[index].extractedRef.localPath),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              )
            ],
          );
        });
  }
}

class DetectionSteps extends StatelessWidget {
  const DetectionSteps(
    this.firstItem, {
    Key key,
  }) : super(key: key);

  final DetectionItem firstItem;

  @override
  Widget build(BuildContext context) {
    int currentStep = 2;
    if (firstItem.extractedRef.upload.percent < 1)
      currentStep = 0;
    else if (firstItem.progress == null) currentStep = 1;
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 5),
          height: 200,
          child: Theme(
            data: ThemeData(
              primaryColor: Colors.red,
            ),
            child: Stepper(
              currentStep: currentStep,
              controlsBuilder: (BuildContext context,
                  {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
                return Container();
              },
              type: StepperType.horizontal,
              steps: [
                Step(
                  title: Text('Upload'),
                  content: LinearProgressIndicator(
                      value: firstItem.extractedRef.upload.percent),
                  isActive: currentStep == 0,
                  state: (currentStep > 0)
                      ? StepState.complete
                      : StepState.indexed,
                ),
                Step(
                  title: Text('Setup'),
                  content: Center(child: CircularProgressIndicator()),
                  isActive: currentStep == 1,
                  state: (currentStep > 1)
                      ? StepState.complete
                      : StepState.indexed,
                ),
                Step(
                  title: Text('Detect'),
                  content: Text(firstItem.progress ?? ''),
                  isActive: currentStep == 2,
                  state: (currentStep > 2)
                      ? StepState.complete
                      : StepState.indexed,
                ),
              ],
              onStepTapped: print,
            ),
          ),
        ),
      ],
    );
  }
}
