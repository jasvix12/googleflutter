import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'send_notification_page.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int _notificationCount = 0;

  @override
  void initState() {
    super.initState();
    _listenForNotifications();
  }

  void _listenForNotifications() {
    FirebaseFirestore.instance
        .collection('notifications')
        .where('read', isEqualTo: false) // Solo cuenta las no leídas
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _notificationCount = snapshot.docs.length;
      });

      // Muestra una notificación local por cada nueva solicitud
      for (var doc in snapshot.docs) {
        String message = doc['message'];
        _showLocalNotification("Nueva solicitud", message);
      }
    });
  }

  Future<void> _showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  void _deleteNotification(String docId) {
    try {
      FirebaseFirestore.instance.collection('notifications').doc(docId).delete().then((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Notificación eliminada')));
      });
    } catch (e) {
      print('Error al eliminar notificación: $e');
    }
  }

  void _markNotificationsAsRead() {
    try {
      FirebaseFirestore.instance.collection('notifications').get().then((snapshot) {
        for (var doc in snapshot.docs) {
          doc.reference.update({'read': true});
        }
      }).then((_) {
        setState(() {
          _notificationCount = 0;
        });
      });
    } catch (e) {
      print('Error al marcar notificaciones como leídas: $e');
    }
  }

  void _showNotificationsModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 400,
          padding: EdgeInsets.all(16),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text("No hay notificaciones"));
              }

              return ListView(
                children: snapshot.data!.docs.map((doc) {
                  return Dismissible(
                    key: Key(doc.id),
                    onDismissed: (direction) => _deleteNotification(doc.id),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    child: ListTile(
                      tileColor: Colors.yellow[200],
                      leading: Icon(Icons.notifications_active, color: Colors.blueAccent),
                      title: Text(doc['message']),
                      subtitle: Text(doc['timestamp']?.toDate().toString() ?? ""),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(doc['message'])),
                        );
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
        );
      },
    ).whenComplete(() => _markNotificationsAsRead()); // Marcar notificaciones como leídas
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[100],
      appBar: AppBar(
        title: Text("Notificaciones"),
        backgroundColor: Colors.yellow[700],
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.notifications, size: 32),
                if (_notificationCount > 0)
                  Positioned(
                    right: -5,
                    top: -5,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '$_notificationCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showNotificationsModal,
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow[700],
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SendNotificationPage()),
            );
          },
          child: Text("Enviar Notificación"),
        ),
      ),
    );
  }
}
