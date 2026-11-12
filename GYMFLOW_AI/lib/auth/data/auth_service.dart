import 'package:firebase_auth/firebase_auth.dart';

class AuthException implements Exception {
  AuthException(this.message);
  final String message;
}

class AuthService {
  AuthService._();

  static final _auth = FirebaseAuth.instance;

  static Stream<User?> get changes => _auth.authStateChanges();
  static Stream<User?> get userChanges => _auth.userChanges();
  static User? get currentUser => _auth.currentUser;

  static Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_message(e.code));
    }
  }

  static Future<void> register(
      String name,
      String email,
      String password,
      ) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user?.updateDisplayName(name.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_message(e.code));
    }
  }

  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_message(e.code));
    }
  }

  static Future<void> signOut() => _auth.signOut();

  static String _message(String code) {
    switch (code) {
      case 'invalid-email':
        return 'El email no es válido.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese email.';
      case 'weak-password':
        return 'La contraseña es muy débil (mínimo 6 caracteres).';
      case 'network-request-failed':
        return 'Sin conexión. Revisá tu internet.';
      case 'too-many-requests':
        return 'Demasiados intentos. Probá más tarde.';
      default:
        return 'Ocurrió un error ($code).';
    }
  }
}