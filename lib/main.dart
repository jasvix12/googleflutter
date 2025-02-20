import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Importa firebase_core
import 'login_page.dart'; // Importa tu pantalla de login

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegúrate de que los widgets estén listos
  await Firebase.initializeApp(); // Inicializa Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(), // Inicia con la página de login
    );
  }
}


