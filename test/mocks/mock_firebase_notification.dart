import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/models/notification_model.dart';
import 'package:dima_app/models/poll_event_notification.dart';
import 'package:dima_app/services/firebase_crud.dart';
import 'package:dima_app/services/firebase_notification.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseNotification extends Mock implements FirebaseNotification {
  static PollEventNotification testPollEventNotification =
      PollEventNotification(
    pollEventId: "test poll event model",
    organizerUid: "test organizer uid",
    title: "notification title",
    body: "notification body",
    isRead: false,
    timestamp: "2023-07-05 15:50:00",
  );

  @override
  bool get isPush => true;

  @override
  Stream<DocumentSnapshot<Object?>>? getUserNotificationsSnapshot(
      {required String uid}) {
    var tmp = {
      "notifications": [testPollEventNotification.toMap()]
    };
    final firestore = FakeFirebaseFirestore();
    firestore
        .collection(NotificationModel.collectionName)
        .doc("test uid")
        .set(tmp);
    var document = FirebaseCrud.readSnapshot(
      firestore.collection(NotificationModel.collectionName),
      "test uid",
    );
    return document;
  }
}
