import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    
    // Solicitar permisos de notificación
    _firebaseMessaging.requestPermission();

    // Obtener el token de FCM (para pruebas)
    _firebaseMessaging.getToken().then((token) {
      print("Token de FCM: $token");
    });

    // Escuchar notificaciones en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message.notification!.body ?? 'Notificación recibida')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notificaciones")),
      body: Center(child: Text("Esperando notificaciones...")),
    );
  }
}

