import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthentication {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> anonymousAuth() async {
    try {
      await _firebaseAuth.signInAnonymously();
    } catch (e) {
      print(e);
    }
  }
}
