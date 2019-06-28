import 'package:firebase_auth/firebase_auth.dart';
import 'package:watermarking_mobile/redux/actions.dart';

class AuthService {
  AuthService();

  /// Receives [FirebaseUser] each time the user signIn or signOut
  Stream<ActionSetAuthState> listenToAuthState() {
    return FirebaseAuth.instance.onAuthStateChanged.map(
        (FirebaseUser firebaseUser) =>
            ActionSetAuthState(userId: firebaseUser?.uid));
  }

  Future<void> signOut() {
    return FirebaseAuth.instance.signOut();
  }
}
