import 'dart:convert';

import 'package:dima_app/providers/preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class Messaging {
  final User? _user;

  Messaging(this._user) {
    print("MEssaging-----------------------------------------");
    print(_user);
    if (_user != null) {
      FirebaseMessaging.instance.subscribeToTopic(_user!.uid);
    } else {
      FirebaseMessaging.instance.deleteToken();
    }
  }

  static Future<void> initMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    String? token = await messaging.getToken();
    print(token);

    print('User granted permission: ${settings.authorizationStatus}');

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.max,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (!Preferences.getBool('isPush')) return;
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.notification}');
      print("FOREE");

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                priority: Priority.max,
                importance: Importance.max,
                icon: 'app_icon',
                // other properties...
              ),
            ));
      }
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.

    // await Firebase.initializeApp();
    /*
    print("Handling a background message: ${message.messageId}");
    print(message.mutableContent)
       print('Got a message whilst in the foreground!');
    print('Message data: ${message.notification}');
    */
    if (!Preferences.getBool('isPush')) return;
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.max,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    print("bg message");

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    // If `onMessage` is triggered with a notification, construct our own
    // local notification to show to users using the created channel.
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              priority: Priority.max,
              importance: Importance.max,
              icon: 'app_icon',
              // other properties...
            ),
          ));
    }
  }

  static Future<void> sendNotification({
    required String topic,
    required String title,
    required String body,
  }) async {
    http.post(
      // hope the site does not break :)
      Uri.parse('https://eventy-messaging.onrender.com/notify_user'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'topic': topic,
        'title': title,
        'body': body,
      }),
    );
  }
}
