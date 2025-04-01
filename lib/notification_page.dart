import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'send_notification_page.dart';
import 'login_page.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationPage extends StatefulWidget {
  final String? userPhotoUrl;
  final String? userName;
  final String? userEmail;

  const NotificationPage({
    Key? key,
    this.userPhotoUrl,
    this.userName,
    this.userEmail,
  }) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int _notificationCount = 0;


  @override
  void initState() {
    super.initState();
    _listenForNotifications();
    _debugPrintUserData();
  }


  void _debugPrintUserData() {

  }

  void _listenForNotifications() {
    FirebaseFirestore.instance
        .collection('notifications')
        .where('read', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _notificationCount = snapshot.docs.length;
      });

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
    ).whenComplete(() => _markNotificationsAsRead());
  }
 // Añade este método para cerrar sesión
  Future<void> _signOut() async {
    try {
      // Cerrar sesión en Firebase
      await FirebaseAuth.instance.signOut();
      
      // Cerrar sesión en Google
      await GoogleSignIn().signOut();
      
      // Navegar de vuelta a la página de login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print('Error al cerrar sesión: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión')),
      );
    }
  }

//Modifica el metodo _showProfileInfo para incluir el boton de cerrar sesion
  void _showProfileInfo(BuildContext context) {
    final name = widget.userName?.isNotEmpty == true
    ? widget.userName!:'No se pude obtener el nombre';

    final email = widget.userEmail?.isNotEmpty == true
    ? widget.userEmail!:'Correo no disponible';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.userName != null)
              Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(widget.userName!),
              ),
            if (widget.userEmail != null)
              Text(
                widget.userEmail!,
                style: TextStyle(color: Colors.grey[600]),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cerrar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); //Cierra el dialogo primero
              _signOut(); //Luego cierra sesion
            },
            child: Text("Cerrar sesion", style: TextStyle(color:Colors.red)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[100],
      appBar: AppBar(
        title: Row(
          children: [
            if (widget.userPhotoUrl != null)
              GestureDetector(
                onTap: () => _showProfileInfo(context),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(widget.userPhotoUrl!),
                  radius: 15,
                ),
              ),
            SizedBox(width: 10),
            Text("Notificaciones"),
          ],
        ),
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