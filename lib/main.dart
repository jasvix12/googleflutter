import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Importa firebase_core
import 'package:firebase_messaging/firebase_messaging.dart';
import 'login_page.dart'; // Importa tu pantalla de login

//maneja las notificaciones cuando la app este cerrada
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Notification en segudo plano: ${message.notification?.title}");
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegúrate de que los widgets estén listos
  await Firebase.initializeApp(); // Inicializa Firebase

FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//Solicitar permisos para recibir notificaciones
FirebaseMessaging messaging = FirebaseMessaging.instance;

NotificationSettings settings = await messaging.requestPermission(
alert: true,
badge: true,
sound: true,
);


if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('Permiso de notificaciones concedido.');
  } else {
    print('Permiso de notificaciones denegado.');
  }

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


