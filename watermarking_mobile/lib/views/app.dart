import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:redux/redux.dart';
import 'package:watermarking_mobile/models/app_state.dart';
import 'package:watermarking_mobile/models/original_image_reference.dart';
import 'package:watermarking_mobile/models/original_images_view_model.dart';
import 'package:watermarking_mobile/models/user_model.dart';
import 'package:watermarking_mobile/redux/actions.dart';
import 'package:watermarking_mobile/views/account_button.dart';
import 'package:watermarking_mobile/views/home_page.dart';
import 'package:watermarking_mobile/views/problems_observer.dart';
import 'package:watermarking_mobile/views/profile_page.dart';
import 'package:watermarking_mobile/views/select_image_observer.dart';
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
                  return (user.waiting)
                      ? const Text('Waiting', textDirection: TextDirection.ltr)
                      : (user.id == null)
                          ? const SigninPage()
                          : const AppWidget();
                })));
  }
}

class AppWidget extends StatelessWidget {
  const AppWidget({Key key}) : super(key: key);

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
          SelectImageObserver(),
          ProblemsObserver(),
        ],
      ),
      body: StoreConnector<AppState, int>(
          converter: (Store<AppState> store) => store.state.bottomNav.index,
          builder: (BuildContext context, int index) {
            return (index == 0) ? const HomePage() : const ProfilePage();
          }),
      // TODO(nickm): when the image reference contains the size,
      // just watch the selected image
      bottomNavigationBar: StoreConnector<AppState, int>(
          converter: (Store<AppState> store) => store.state.bottomNav.index,
          builder: (BuildContext context, int index) {
            return BottomNavigationBar(
              currentIndex: index,
              onTap: (int index) {
                dynamic action = (index == 1)
                    ? ActionShowBottomSheet(show: true)
                    : ActionSetBottomNav(index: index);
                StoreProvider.of<AppState>(context).dispatch(action);
              },
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home, key: Key('HomeTabIcon')),
                  title: Text('Home'),
                ),
                BottomNavigationBarItem(
                  icon: StoreConnector<AppState, OriginalImageReference>(
                      converter: (Store<AppState> store) =>
                          store.state.originals.selectedImage,
                      builder: (BuildContext context,
                          OriginalImageReference imageRef) {
                        return Container(
                          width: 50,
                          height: 50,
                          child: (imageRef == null)
                              ? Icon(Icons.touch_app, key: Key('ImageTabIcon'))
                              : Image.network(
                                  imageRef.url,
                                  key: Key('ImageTabImage'),
                                ),
                        );
                      }),
                  title: Text(''),
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person, key: Key('ProfileTabIcon')),
                    title: Text('Profile'))
              ],
            );
          }),
      floatingActionButton: StoreConnector<AppState, OriginalImagesViewModel>(
        converter: (Store<AppState> store) => store.state.originals,
        builder: (BuildContext context, OriginalImagesViewModel viewModel) {
          if (viewModel.selectedImage == null) {
            return Container(
              height: 0,
              width: 0,
            );
          }
          return FloatingActionButton(
            key: Key('ScanFAB'),
            onPressed: () async {
              String path = await platform.invokeMethod('startDetection', {
                'width': viewModel.selectedWidth,
                'height': viewModel.selectedHeight
              });
              platform.invokeMethod('dismiss');
              StoreProvider.of<AppState>(context)
                  .dispatch(ActionProcessExtractedImage(filePath: path));
            },
            tooltip: 'Scan',
            child: Icon(Icons.search),
          );
        },
      ),
    );
  }
}
