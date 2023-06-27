// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/constants/preferences.dart';
import 'package:dima_app/firebase_options.dart';
import 'package:dima_app/models/notification_model.dart';
import 'package:dima_app/models/poll_event_notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'date_methods.dart';
import 'firebase_crud.dart';
import 'firebase_user.dart';

// DO NOT show the notification, foreground already does it
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  // If `onMessage` is triggered with a notification, construct our own
  // local notification to show to users using the created channel.
  if (notification != null && android != null) {
    print("bg message ${notification.title}");
    print("bg message ${notification.body}");
  }
}

class FirebaseNotification extends ChangeNotifier {
  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;
  bool _isPush = Preferences.getBool('isPush');
  bool get isPush => _isPush;

  FirebaseNotification(this._messaging, this._firestore);

  CollectionReference get notificationCollection =>
      _firestore.collection(NotificationModel.collectionName);

  Stream<DocumentSnapshot<Object?>>? getUserNotificationsSnapshot({
    required String uid,
  }) {
    try {
      var document = FirebaseCrud.readSnapshot(notificationCollection, uid);
      return document;
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return null;
  }

  Future<void> updateNotification({
    required BuildContext context,
    required PollEventNotification notification,
  }) async {
    try {
      String uid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
      var document = await FirebaseCrud.readDoc(notificationCollection, uid);
      if (document!.exists) {
        NotificationModel notificationModel =
            NotificationModel.fromMap(document.data() as Map<String, dynamic>);
        List<PollEventNotification> updatedNotifications = [];
        for (PollEventNotification n in notificationModel.notifications) {
          updatedNotifications.add(PollEventNotification(
            pollEventId: n.pollEventId,
            organizerUid: n.organizerUid,
            title: n.title,
            body: n.body,
            isRead: n == notification || n.isRead,
            timestamp: DateFormatter.toUtcString(n.timestamp),
          ));
        }
        await FirebaseCrud.updateDoc(
          notificationCollection,
          uid,
          "notifications",
          updatedNotifications.map((e) => e.toMap()).toList(),
        );
      }
    } on FirebaseException catch (e) {
      print(e.message!);
    }
  }

  Future<void> deleteNotification({
    required BuildContext context,
    required PollEventNotification notification,
  }) async {
    try {
      String uid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
      var document = await FirebaseCrud.readDoc(notificationCollection, uid);
      if (document!.exists) {
        NotificationModel notificationModel =
            NotificationModel.fromMap(document.data() as Map<String, dynamic>);
        List<PollEventNotification> updatedNotifications = [];
        for (PollEventNotification n in notificationModel.notifications) {
          if (n != notification) {
            updatedNotifications.add(PollEventNotification(
              pollEventId: n.pollEventId,
              organizerUid: n.organizerUid,
              title: n.title,
              body: n.body,
              isRead: n.isRead,
              timestamp: DateFormatter.toUtcString(n.timestamp),
            ));
          }
        }
        if (updatedNotifications.isEmpty) {
          await FirebaseCrud.deleteDoc(notificationCollection, uid);
        } else {
          await FirebaseCrud.updateDoc(
            notificationCollection,
            uid,
            "notifications",
            updatedNotifications.map((e) => e.toMap()).toList(),
          );
        }
      }
    } on FirebaseException catch (e) {
      print(e.message!);
    }
  }

  Future<void> deleteAllNotifications({
    required BuildContext context,
  }) async {
    try {
      String uid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
      var document = await FirebaseCrud.readDoc(notificationCollection, uid);
      if (document!.exists) {
        await FirebaseCrud.deleteDoc(notificationCollection, uid);
      }
    } on FirebaseException catch (e) {
      // showSnackBar(context, e.message!);
      print(e.message!);
    }
  }

  Future<void> requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted permission (can be provisional)');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    _isPush = true;
    Preferences.setBool('isPush', true);
    notifyListeners();
  }

  Future<void> deleteToken() async {
    await _messaging.deleteToken();
    _isPush = false;
    Preferences.setBool('isPush', false);
    notifyListeners();
  }

  Future<void> initHandlers() async {
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

    // ignore: unused_local_variable
    const initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    /*
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      firebaseMessagingForegroundHandler(
        message: message,
        flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
        channel: channel,
      );
    });
    */

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  firebaseMessagingForegroundHandler({
    required RemoteMessage message,
    required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    required AndroidNotificationChannel channel,
  }) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.notification}');
    print("FOREsE");

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
        ),
      );
      notifyListeners();
    }
  }

  static Future<void> sendNotification({
    required String pollEventId,
    required String organizerUid,
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
        'organizerUid': organizerUid,
        'pollEventId': pollEventId,
        'topic': topic,
        'title': title,
        'body': body,
      }),
    );
    print("Sent notification");
  }
}
