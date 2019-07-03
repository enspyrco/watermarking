import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:watermarking_mobile/models/app_state.dart';
import 'package:watermarking_mobile/models/images_view_model.dart';
import 'package:watermarking_mobile/redux/actions.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ImagesViewModel>(
      converter: (Store<AppState> store) => store.state.images,
      builder: (BuildContext context, ImagesViewModel viewModel) {
        return Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 150,
                    child: ImagesList(
                      viewModel: viewModel,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (viewModel.selectedImage != null)
                  Container(
                    height: 200,
                    child: Image.network(viewModel.selectedImage.url),
                  )
              ],
            )
          ],
        );
      },
    );
  }
}

class ImagesList extends StatelessWidget {
  const ImagesList({Key key, @required this.viewModel}) : super(key: key);

  final ImagesViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: viewModel.images.length,
      itemBuilder: (BuildContext context, int index) {
        return SelectImageItem(viewModel: viewModel, index: index);
      },
    );
  }
}

class SelectImageItem extends StatefulWidget {
  const SelectImageItem({
    Key key,
    @required this.viewModel,
    @required this.index,
  }) : super(key: key);

  final ImagesViewModel viewModel;
  final int index;

  @override
  _SelectImageItemState createState() => _SelectImageItemState();
}

// TODO(nickm): when the image reference contains the size, width and height
// can be removed and this widget can be refactored - the Image's resolve
// callback removed and change the widget to Stateless
class _SelectImageItemState extends State<SelectImageItem> {
  int width;
  int height;

  @override
  Widget build(BuildContext context) {
    Image image = Image.network(widget.viewModel.images[widget.index].url);
    Completer<ui.Image> completer = Completer<ui.Image>();
    image.image.resolve(ImageConfiguration()).addListener(
        (ImageInfo info, bool _) => completer.complete(info.image));

    // use box decoration to indicate selected status
    BoxDecoration boxDecoration = (widget.viewModel.images[widget.index] ==
            widget.viewModel.selectedImage)
        ? selectedBoxDecoration()
        : unselectedBoxDecoration();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: InkWell(
            child: Container(
              height: 100,
              width: 100,
              decoration: boxDecoration,
              child: image,
            ),
            onTap: () {
              if (width != null && height != null) {
                StoreProvider.of<AppState>(context).dispatch(
                    ActionSetSelectedImage(
                        image: widget.viewModel.images[widget.index],
                        width: width,
                        height: height));
              }
            },
          ),
        ),
        FutureBuilder<ui.Image>(
          future: completer.future,
          builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
            if (snapshot.hasData) {
              width = snapshot.data.width;
              height = snapshot.data.height;
              return Text(
                '${width}x$height',
              );
            } else {
              return Text('Loading...');
            }
          },
        ),
      ],
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
