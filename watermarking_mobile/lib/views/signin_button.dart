import 'package:flutter/material.dart';

Widget signinButton(String title, String uri,
    [Color color = const Color.fromRGBO(68, 68, 76, .8)]) {
  return Container(
    width: 200.0,
    child: Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            uri,
            width: 25.0,
          ),
          Padding(
            child: Text(
              'Sign in with $title',
              style: TextStyle(
                fontFamily: 'Roboto',
                color: color,
              ),
            ),
            padding: const EdgeInsets.only(left: 15.0),
          ),
        ],
      ),
    ),
  );
}

Widget phoneSigninButton(String title,
    [Color color = const Color.fromRGBO(68, 68, 76, .8)]) {
  return Container(
    width: 200.0,
    child: Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.local_phone,
            size: 25.0,
          ),
          // Image.asset(
          //   uri,
          //   width: 25.0,
          // ),
          Padding(
            child: Text(
              '$title',
              style: TextStyle(
                fontFamily: 'Roboto',
                color: color,
              ),
            ),
            padding: const EdgeInsets.only(left: 15.0),
          ),
        ],
      ),
    ),
  );
}
