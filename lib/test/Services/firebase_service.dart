import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotif() async {

       NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true, // Allow notification alerts
      announcement: true, // Allow notifications for announcements
      badge: true, // Allow notification badges
      carPlay: false, // Not applicable on Flutter (optional)
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission for notifications');
    } else {
      print('User declined or has not granted permission for notifications');
    }


    final fcmToken = await _firebaseMessaging.getToken();
    print('*******************');
    print('FCM token: $fcmToken');


    FirebaseMessaging.onMessage.listen((RemoteMessage message) {

      print('Received message in foreground: $message');
      _handleMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {

      print('Received message and opened app: $message');
      _handleMessage(message);
    });


  }

  void _handleMessage(RemoteMessage message) {
    // Extract and handle data from the message notification and data payload
    // Update UI, navigate to a specific screen, or perform other actions based on the message content
    print('Notification data: ${message.notification?.title}, ${message.notification?.body}');
    print('Message data: ${message.data}');
  }
}