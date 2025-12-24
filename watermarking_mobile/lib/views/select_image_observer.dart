import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:watermarking_mobile/models/app_state.dart';
import 'package:watermarking_mobile/views/select_image_bottom_sheet.dart';

class SelectImageObserver extends StatefulWidget {
  const SelectImageObserver({super.key});

  @override
  State<SelectImageObserver> createState() => _SelectImageObserverState();
}

class _SelectImageObserverState extends State<SelectImageObserver> {
  PersistentBottomSheetController? bottomSheetController;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, bool>(
        distinct: true,
        converter: (Store<AppState> store) =>
            store.state.bottomNav.shouldShowBottomSheet,
        onDidChange: (bool? previous, bool shouldShowBottomSheet) {
          if (shouldShowBottomSheet) {
            // show the bottom sheet and save the returned controller
            bottomSheetController = Scaffold.of(context)
                .showBottomSheet(
                    (BuildContext builder) => const SelectImageBottomSheet());
          } else {
            bottomSheetController?.close();
          }
        },
        builder: (BuildContext context, bool shouldShowBottomSheet) {
          return const SizedBox.shrink();
        });
  }
}
