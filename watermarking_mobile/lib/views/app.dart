import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:redux/redux.dart';
import 'package:watermarking_mobile/models/app_state.dart';
import 'package:watermarking_mobile/models/image_reference.dart';
import 'package:watermarking_mobile/models/images_view_model.dart';
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
                  icon: Icon(Icons.home),
                  title: Text('Home'),
                ),
                BottomNavigationBarItem(
                  icon: StoreConnector<AppState, ImageReference>(
                      converter: (Store<AppState> store) =>
                          store.state.images.selectedImage,
                      builder: (BuildContext context, ImageReference imageRef) {
                        return Container(
                          width: 50,
                          height: 50,
                          child: (imageRef == null)
                              ? Icon(Icons.touch_app)
                              : Image.network(imageRef.url),
                        );
                      }),
                  title: Text(''),
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), title: Text('Profile'))
              ],
            );
          }),
      floatingActionButton: StoreConnector<AppState, ImagesViewModel>(
        converter: (Store<AppState> store) => store.state.images,
        builder: (BuildContext context, ImagesViewModel viewModel) {
          return FloatingActionButton(
            onPressed: () async {
              if (viewModel.selectedImage != null) {
                String path = await platform.invokeMethod('startDetection', {
                  'width': viewModel.selectedWidth,
                  'height': viewModel.selectedHeight
                });
                platform.invokeMethod('dismiss');
                StoreProvider.of<AppState>(context)
                    .dispatch(ActionSetDetectedImage(filePath: path));
              }
            },
            tooltip: 'Scan',
            child: Icon(Icons.search),
          );
        },
      ),
    );
  }
}
