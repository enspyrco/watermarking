import 'package:watermarking_mobile/redux/actions.dart';
import 'package:watermarking_mobile/services/auth_service.dart';

class MockAuthService implements AuthService {
  MockAuthService();

  @override
  Stream<ActionSetAuthState> listenToAuthState() async* {
    yield ActionSetAuthState(
        userId: '0',
        photoUrl:
            'https://lh4.googleusercontent.com/-q5LxfJgDNZU/AAAAAAAAAAI/AAAAAAAABCc/Qg-SpkylHCA/photo.jpg');
  }

  @override
  Future<void> signOut() {
    return Future<void>.delayed(const Duration(seconds: 1));
  }
}
