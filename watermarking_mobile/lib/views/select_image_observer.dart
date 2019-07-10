import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:watermarking_mobile/models/app_state.dart';
import 'package:watermarking_mobile/views/select_image_bottom_sheet.dart';

class SelectImageObserver extends StatefulWidget {
  const SelectImageObserver({Key key}) : super(key: key);

  @override
  _SelectImageObserverState createState() => _SelectImageObserverState();
}

class _SelectImageObserverState extends State<SelectImageObserver> {
  PersistentBottomSheetController<dynamic> bottomSheetController;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, bool>(
        distinct: true,
        converter: (Store<AppState> store) =>
            store.state.bottomNav.shouldShowBottomSheet,
        onWillChange: (bool shouldShowBottomSheet) {
          if (shouldShowBottomSheet) {
            // show the bottom sheet and save the returned controller
            bottomSheetController = Scaffold.of(context)
                .showBottomSheet<SelectImageBottomSheet>(
                    (BuildContext builder) => const SelectImageBottomSheet());
          } else {
            bottomSheetController?.close();
          }
        },
        builder: (BuildContext context, bool shouldShowBottomSheet) {
          return const EmptyContainer();
        });
  }
}

class EmptyContainer extends StatelessWidget {
  const EmptyContainer({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0,
      height: 0,
    );
  }
}
