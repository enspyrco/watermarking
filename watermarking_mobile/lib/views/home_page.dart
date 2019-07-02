import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:watermarking_mobile/models/app_state.dart';
import 'package:watermarking_mobile/models/images_view_model.dart';
import 'package:watermarking_mobile/redux/actions.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: StoreConnector<AppState, ImagesViewModel>(
          converter: (Store<AppState> store) => store.state.images,
          builder: (BuildContext context, ImagesViewModel viewModel) {
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: viewModel.images.length,
              itemBuilder: (BuildContext context, int index) {
                Image image = Image.network(viewModel.images[index].url);
                Completer<ui.Image> completer = Completer<ui.Image>();
                image.image.resolve(ImageConfiguration()).addListener(
                    (ImageInfo info, bool _) => completer.complete(info.image));

                // use box decoration to indicate selected status
                BoxDecoration boxDecoration =
                    (viewModel.images[index] == viewModel.selectedImage)
                        ? selectedBoxDecoration()
                        : unselectedBoxDecoration();

                return Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        InkWell(
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: boxDecoration,
                            child: image,
                          ),
                          onTap: () {
                            StoreProvider.of<AppState>(context).dispatch(
                                ActionSetSelectedImage(
                                    image: viewModel.images[index]));
                          },
                        ),
                        FutureBuilder<ui.Image>(
                          future: completer.future,
                          builder: (BuildContext context,
                              AsyncSnapshot<ui.Image> snapshot) {
                            if (snapshot.hasData) {
                              return new Text(
                                '${snapshot.data.width}x${snapshot.data.height}',
                              );
                            } else {
                              return new Text('Loading...');
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  BoxDecoration unselectedBoxDecoration() {
    return BoxDecoration(
      border: Border.all(
        width: 1,
        color: Colors.blueGrey,
      ),
      borderRadius: BorderRadius.all(Radius.circular(3.0)),
    );
  }

  BoxDecoration selectedBoxDecoration() {
    return BoxDecoration(
      border: Border.all(
        width: 2,
        color: Colors.blueAccent,
      ),
      borderRadius: BorderRadius.all(Radius.circular(3.0)),
    );
  }
}
