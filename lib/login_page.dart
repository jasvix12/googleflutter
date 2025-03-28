import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'google_sign_in_api.dart'; // Asegúrate de importar la clase
import 'notification_page.dart'; // Asegúrate de importar la nueva página
import 'package:firebase_auth/firebase_auth.dart'; // Importa FirebaseAuth

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GoogleSignInAccount? _user;

  // Función para iniciar sesión
  Future<void> signIn() async {
    try {
      // Inicia sesión con Google
      final usuario = await GoogleSignInApi.login();
      if (usuario != null) {
        setState(() {
          _user = usuario;
        });
        print('Inicio de sesión exitoso: ${_user!.displayName}');

        // Autenticar con Firebase
        final GoogleSignInAuthentication googleAuth = await usuario.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Inicia sesión en Firebase
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        if (userCredential.user != null) {
          // Redirige a la página de notificaciones después de iniciar sesión
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationPage(
                userPhotoUrl: _user!.photoUrl ?? '', // Pasar la URL de la foto de perfil
                userName: _user?.displayName ?? '', //Nombre del usuario
                userEmail: _user?.email ?? '', //Email del usuario
              ),
            ),
          );
        }
      }
    } catch (error) {
      print('Error de inicio de sesión: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login with Google"),
      ),
      body: Container(
        color: Colors.yellow, // Establecemos el color de fondo a amarillo
        child: Center(
          child: _user == null
              ? ElevatedButton.icon(
                  icon: const FaIcon(
                    size: 40.0,
                    FontAwesomeIcons.google,
                    color: Colors.green,
                  ),
                  onPressed: signIn,
                  label: const Text(
                    "Login With Google",
                    style: TextStyle(fontSize: 20.0, color: Colors.blue),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Bienvenido, ${_user!.displayName}'),
                  ],
                ),
        ),
      ),
    );
  }
}




