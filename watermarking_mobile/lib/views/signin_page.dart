import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:watermarking_core/watermarking_core.dart';
import 'package:watermarking_mobile/views/signin_button.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});
  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  Stream<String>? _stream;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder<String>(
          stream: _stream,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
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
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      yield 'sign in cancelled';
      return;
    }
    yield 'got google user';
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    yield 'got google auth';
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    StoreProvider.of<AppState>(context).dispatch(const ActionSignin());
    yield 'signInWithGoogle succeeded: ${userCredential.user}';
    return;
  }

  Stream<String> _signInWithFacebook() async* {
    yield 'starting';
    // final FacebookLoginResult result = await FacebookLogin().logInWithReadPermissions(['email']);
    yield 'logged in with facebook';
    // final AuthCredential credential = FacebookAuthProvider.credential(accessToken: result.accessToken.token);
    // final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    // yield 'signInWithFacebook succeeded: ${userCredential.user}';

    return;
  }

  Widget _buildSigninButtons() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
            ),
            onPressed: () {
              setState(() {
                _stream = _signInWithGoogle();
              });
            },
            child: signinButton('Google', 'assets/google.png'),
          ),
          const Padding(padding: EdgeInsets.all(10.0)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(58, 89, 152, 1.0),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _stream = _signInWithFacebook();
              });
            },
            child: signinButton('Facebook', 'assets/facebook.png', Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingWidget() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
