import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:watermarking_mobile/models/app_state.dart';
import 'package:watermarking_mobile/models/user_model.dart';

class AccountButton extends StatelessWidget {
  AccountButton({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Center(
        child: StoreConnector<AppState, UserModel>(
            distinct: true,
            converter: (Store<AppState> store) => store.state.user,
            builder: (BuildContext context, UserModel user) {
              if (user.waiting || user.photoUrl == null) {
                return const CircularProgressIndicator(
                    value: null,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber));
              }
              return Container(
                width: 40.0,
                height: 40.0,
                margin: const EdgeInsets.only(right: 10.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: Image.network(user.photoUrl).image),
                  border: Border.all(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
              );
            }),
      ),
    );
  }
}
