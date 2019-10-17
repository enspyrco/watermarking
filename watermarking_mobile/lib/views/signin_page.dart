import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
// import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:watermarking_mobile/models/app_state.dart';
import 'package:watermarking_mobile/redux/actions.dart';
import 'package:watermarking_mobile/views/signin_button.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({Key key}) : super(key: key);
  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  Stream<String> _stream;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder<String>(
          stream: _stream,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return _buildSigninButtons();
              case ConnectionState.waiting:
                return _buildWaitingWidget();
              case ConnectionState.active:
                return Center(child: Text('${snapshot.data}'));
              case ConnectionState.done:
                return Center(child: Text('${snapshot.data} (closed)'));
            }
          }),
    );
  }

  Stream<String> _signInWithGoogle() async* {
    yield 'starting';
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    yield 'got google user';
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    yield 'got google auth';
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final FirebaseUser user =
        await FirebaseAuth.instance.signInWithCredential(credential);
    StoreProvider.of<AppState>(context).dispatch(const ActionSignin());
    yield 'signInWithGoogle succeeded: $user';
    return;
  }

  Stream<String> _signInWithFacebook() async* {
    yield 'starting';
    // final FacebookLoginResult result = await FacebookLogin().logInWithReadPermissions(['email']);
    yield 'logged in with facebook';
    // final AuthCredential credential = FacebookAuthProvider.getCredential(accessToken: result.accessToken.token);
    // final FirebaseUser user = await FirebaseAuth.instance.signInWithCredential(credential);
    // yield 'signInWithFacebook succeeded: $user';

    return;
  }

  Widget _buildSigninButtons() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          MaterialButton(
            child: signinButton('Google', 'assets/google.png'),
            onPressed: () {
              setState(() {
                _stream = _signInWithGoogle();
              });
            },
            color: Colors.white,
          ),
          const Padding(padding: EdgeInsets.all(10.0)),
          MaterialButton(
            child:
                signinButton('Facebook', 'assets/facebook.png', Colors.white),
            onPressed: () {
              setState(() {
                _stream = _signInWithFacebook();
              });
            },
            color: const Color.fromRGBO(58, 89, 152, 1.0),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingWidget() {
    return Center(
      child: const CircularProgressIndicator(),
    );
  }
}
