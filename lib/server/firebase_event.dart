import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/server/tables/event_collection.dart';
import 'package:dima_app/widgets/show_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_crud.dart';

class FirebaseEvent extends ChangeNotifier {
  final FirebaseFirestore _firestore;

  FirebaseEvent(this._firestore);

  CollectionReference get eventCollection =>
      _firestore.collection(EventCollection.collectionName);

  Future<EventCollection> createEvent({
    required BuildContext context,
    required String eventName,
    required String organizerUid,
    required String eventDesc,
    required String deadline,
    required Map<String, dynamic> dates,
    required Map<String, dynamic> location,
    required bool public,
  }) async {
    EventCollection event = EventCollection(
      eventName: eventName,
      organizerUid: organizerUid,
      eventDesc: eventDesc,
      deadline: deadline,
      dates: dates,
      location: location,
      public: public,
    );
    try {
      String eventId = "${eventName}_$organizerUid";
      var eventExistence = await FirebaseCrud.readDoc(eventCollection, eventId);
      if (eventExistence!.exists) {
        // ignore: use_build_context_synchronously
        showSnackBar(context, "A Event with this name already exists");
      }
      await eventCollection.doc(eventId).set(event.toMap());
    } on FirebaseAuthException catch (e) {
      // showSnackBar(context, e.message!);
      print(e.message!);
    }
    return event;
  }

  Future<EventCollection?> getEventData(
    BuildContext context,
    String id,
  ) async {
    try {
      var eventDataDoc = await FirebaseCrud.readDoc(eventCollection, id);
      var tmp = eventDataDoc?.data() as Map<String, dynamic>;
      var eventDetails = EventCollection.fromMap(tmp);
      return eventDetails;
    } on FirebaseException catch (e) {
      showSnackBar(context, e.message!);
    }
    return null;
  }

  Future<List<EventCollection>> getUserEvents(
    BuildContext context,
    String userUid,
  ) async {
    try {
      var documents =
          await eventCollection.where("inviteeId", isEqualTo: userUid).get();
      if (documents.docs.isNotEmpty) {
        final List<EventCollection> events = documents.docs.map((doc) {
          return EventCollection.fromMap(doc as Map<String, dynamic>);
        }).toList();
        return events;
      }
      return [];
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return [];
  }
}
