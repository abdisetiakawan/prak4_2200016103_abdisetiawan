import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> signIn(String email, String password) async {
    return _guard(() async {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    });
  }

  Future<String?> signUp(String displayName, String email, String password) async {
    return _guard(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName);
      }
      return null;
    });
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String?> _guard(Future<String?> Function() cb) async {
    try {
      _setLoading(true);
      return await cb();
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Terjadi kesalahan otentikasi.';
    } catch (e) {
      return 'Kesalahan tak terduga: $e';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }
}
