import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:watermarking_mobile/models/app_state.dart';
import 'package:watermarking_mobile/models/detected_image_view_model.dart';
import 'package:watermarking_mobile/models/images_view_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ImagesViewModel>(
      converter: (Store<AppState> store) => store.state.images,
      builder: (BuildContext context, ImagesViewModel viewModel) {
        return Column(
          children: <Widget>[
            StoreConnector<AppState, DetectedImageViewModel>(
                converter: (Store<AppState> store) => store.state.detectedImage,
                builder:
                    (BuildContext context, DetectedImageViewModel viewModel) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if (viewModel.detectedImagePath != null)
                        Container(
                          height: 200,
                          child: Image.file(File(viewModel.detectedImagePath)),
                        ),
                      Text(viewModel.watermarkDetectionProgress),
                      Text(viewModel.watermarkDetectionResult),
                    ],
                  );
                }),
          ],
        );
      },
    );
  }
}
