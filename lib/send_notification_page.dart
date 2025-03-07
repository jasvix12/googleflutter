import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SendNotificationPage extends StatefulWidget {
  @override
  _SendNotificationPageState createState() => _SendNotificationPageState();
}

class _SendNotificationPageState extends State<SendNotificationPage> {
  final TextEditingController _messageController = TextEditingController();

  Future<void> _sendNotification() async {
    String message = _messageController.text.trim();
    if (message.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("El mensaje no puede estar vacio")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Debes iniciar sesion para enviar notificaciones")),
        );
        return;
      }
    
    try{
    await FirebaseFirestore.instance.collection('notifications').add({
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Notificación enviada")),
    );

    _messageController.clear();
  } catch (e) {
    print("Error al enviar notificacion: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar (content: Text("Error al enviar notificacion")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enviar Notificación"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: "Mensaje",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendNotification,
              child: Text("Enviar Notificación"),
            ),
          ],
        ),
      ),
    );
  }
}