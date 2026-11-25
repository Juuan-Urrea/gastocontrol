import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

/// Autenticacion con Firebase Auth (correo y contrasena).
/// Es un GetxService: se registra una sola vez con Get.put y vive toda la app.
class AuthService extends GetxService {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Emite el usuario actual cada vez que inicia o cierra sesion (tambien al abrir la app).
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return cred.user!;
  }

  Future<User> signUp(String name, String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = cred.user!;
    try {
      await user.updateDisplayName(name);
    } catch (_) {
      // El nombre tambien se guarda en Firestore; si esto falla no es critico.
    }
    return user;
  }

  Future<void> signOut() => _auth.signOut();

  /// Traduce los codigos de error de Firebase Auth a mensajes para el usuario.
  static String messageFor(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'El correo no tiene un formato válido.';
      case 'user-disabled':
        return 'Esta cuenta fue deshabilitada.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return 'Correo o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese correo. Inicia sesión.';
      case 'weak-password':
        return 'La contraseña es muy débil (mínimo 6 caracteres).';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera un momento e inténtalo de nuevo.';
      case 'network-request-failed':
        return 'Sin conexión a internet. Revisa tu red.';
      case 'operation-not-allowed':
        return 'El inicio de sesión con correo no está activado en Firebase (Authentication → Método de acceso).';
      default:
        return 'No se pudo completar la operación (${e.code}).';
    }
  }
}
