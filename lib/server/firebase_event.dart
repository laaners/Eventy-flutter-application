import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/server/tables/event_collection.dart';
import 'package:dima_app/server/tables/poll_event_invite_collection.dart';
import 'package:dima_app/widgets/show_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'date_methods.dart';
import 'firebase_crud.dart';
import 'firebase_poll_event_invite.dart';
import 'firebase_user.dart';

class FirebaseEvent extends ChangeNotifier {
  final FirebaseFirestore _firestore;

  FirebaseEvent(this._firestore);

  CollectionReference get eventCollection =>
      _firestore.collection(EventCollection.collectionName);

  Future<EventCollection?> createEvent({
    required BuildContext context,
    required String eventName,
    required String organizerUid,
    required String eventDesc,
    required Map<String, dynamic> date,
    required Map<String, dynamic> location,
    required bool public,
    required bool canInvite,
  }) async {
    EventCollection event = EventCollection(
      eventName: eventName,
      organizerUid: organizerUid,
      eventDesc: eventDesc,
      date: date,
      location: location,
      public: public,
      canInvite: canInvite,
    );
    try {
      String eventId = "${eventName}_$organizerUid";
      var eventExistence = await FirebaseCrud.readDoc(eventCollection, eventId);
      if (eventExistence!.exists) {
        return null;
      }
      await eventCollection.doc(eventId).set(event.toMap());
    } on FirebaseAuthException catch (e) {
      // showSnackBar(context, e.message!);
      print(e.message!);
    }
    return event;
  }

  Future<EventCollection?> getEventData({
    required BuildContext context,
    required String id,
  }) async {
    try {
      var eventDataDoc = await FirebaseCrud.readDoc(eventCollection, id);
      if (!eventDataDoc!.exists) {
        return null;
      }
      var tmp = eventDataDoc.data() as Map<String, dynamic>;
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

  Future<List<Map<String, dynamic>>> getOtherUserPublicOrInvitedPolls(
    BuildContext context,
    String userUid,
  ) async {
    try {
      var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
      List<PollEventInviteCollection> curUserInvites =
          await Provider.of<FirebasePollEventInvite>(context, listen: false)
              .getInvitesFromUserId(context, curUid);
      List<String> curUserInvitesIds =
          curUserInvites.map((e) => e.pollEventId).toList();

      var documents =
          await eventCollection.where("organizerUid", isEqualTo: userUid).get();

      if (documents.docs.isNotEmpty) {
        List<Map<String, dynamic>> polls = documents.docs.where((doc) {
          var tmp = doc.data() as Map<String, dynamic>;
          return tmp["public"] == true || curUserInvitesIds.contains(doc.id);
        }).map((doc) {
          var tmp = doc.data() as Map<String, dynamic>;
          var eventDetails = EventCollection.fromMap(tmp);
          bool invited = curUserInvitesIds.contains(doc.id);
          return {
            "eventDetails": eventDetails,
            "invited": invited,
            "id": doc.id
          };
        }).toList();

        // check if the date for one event was met, if true then update the database by deleting it (and creating corresponding an event)
        polls = polls.where((e) {
          EventCollection eventData = e["eventDetails"] as EventCollection;
          String nowDate =
              DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());

          String eventDate =
              "${eventData.date["date"]} ${eventData.date["end"]}:00";
          DateFormat f = DateFormat("yyyy-MM-dd HH:mm:ss");
          DateTime eventDateTime =
              f.parse(eventDate).add(const Duration(days: 5));

          eventDate = DateFormatter.dateTime2String(eventDateTime);

          // delete if older than 5 days
          if (DateFormatter.toLocalString(eventDate).compareTo(nowDate) > 0) {
            return true;
          }

          // deadline reached, delete the poll
          deletePoll(context: context, pollId: e["id"]);
          return false;
        }).toList();
        return polls;
      }
      return [];
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return [];
  }
}
