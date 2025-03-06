import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SendNotificationPage extends StatefulWidget {
  @override
  _SendNotificationPageState createState() => _SendNotificationPageState();
}

class _SendNotificationPageState extends State<SendNotificationPage> {
  final TextEditingController _messageController = TextEditingController();

  Future<void> _sendNotification() async {
    String message = _messageController.text.trim();
    if (message.isEmpty) return;

    await FirebaseFirestore.instance.collection('notifications').add({
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Notificación enviada")),
    );

    _messageController.clear();
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