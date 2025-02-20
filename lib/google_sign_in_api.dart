import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInApi {
  static final _googleSignin = GoogleSignIn();

  // Método para iniciar sesión
  static Future<GoogleSignInAccount?> login() => _googleSignin.signIn();

  // Método para cerrar sesión
  static Future signOut() => _googleSignin.signOut();

  // Método para desconectar
  static Future chaolin() => _googleSignin.disconnect();

  // Método para verificar si el usuario está conectado
  static Future<bool> isSignedIn() => _googleSignin.isSignedIn();
}




