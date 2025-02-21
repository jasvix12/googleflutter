import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _token;

  @override
  void initState() {
    super.initState();
    
    // Solicitar permisos de notificación
    _firebaseMessaging.requestPermission();

    // Obtener el token de FCM (para pruebas)
    _firebaseMessaging.getToken().then((token) {
      setState(() {
        _token = token;
      });
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

  Future<void> _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Permisos concedidos")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Permisos denegados")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notificaciones")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Esperando notificaciones..."),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _requestPermission,
              child: Text("Solicitar Permisos"),
            ),
            SizedBox(height: 20),
            if (_token != null) Text("Token de FCM: $_token"),
          ],
        ),
      ),
    );
  }
}