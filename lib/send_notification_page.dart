import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SendNotificationPage extends StatefulWidget {
  @override
  _SendNotificationPageState createState() => _SendNotificationPageState();
}

class _SendNotificationPageState extends State<SendNotificationPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> _sendNotification() async {
    String message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Guardar notificación en Firestore
    await FirebaseFirestore.instance.collection('notifications').add({
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false, // Nuevo campo para manejar el estado de lectura
    });

    // Enviar notificación push con Firebase Cloud Messaging
    await _sendPushNotification(message);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Notificación enviada")),
    );

    _messageController.clear();
  }

  Future<void> _sendPushNotification(String message) async {
    try {
      await FirebaseFirestore.instance.collection('tokens').get().then((snapshot) {
        for (var doc in snapshot.docs) {
          String token = doc['token'];
          _sendToToken(token, message);
        }
      });
    } catch (e) {
      print("Error al enviar notificación: $e");
    }
  }

  Future<void> _sendToToken(String token, String message) async {
    final body = {
      "to": token,
      "notification": {
        "title": "Nueva Solicitud",
        "body": message,
      },
      "priority": "high",
    };

    await FirebaseFirestore.instance.collection('fcm_messages').add(body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[100],
      appBar: AppBar(
        title: Text("Enviar Notificación"),
        backgroundColor: Colors.yellow[700],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: "Mensaje",
                border: OutlineInputBorder(),
                fillColor: Colors.yellow[200],
                filled: true,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                foregroundColor: Colors.white,
              ),
              onPressed: _sendNotification,
              child: Text("Enviar Notificación"),
            ),
          ],
        ),
      ),
    );
  }
}
