// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:dima_app/server/firebase_poll_event.dart';
import 'package:dima_app/server/firebase_poll_event_invite.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/tables/event_location_collection.dart';
import 'package:dima_app/server/tables/poll_event_collection.dart';
import 'package:dima_app/server/tables/poll_event_invite_collection.dart';
import 'package:dima_app/widgets/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_crud.dart';

class FirebaseEventLocation extends ChangeNotifier {
  final FirebaseFirestore _firestore;

  FirebaseEventLocation(this._firestore);

  CollectionReference get eventLocationCollection =>
      _firestore.collection(EventLocationCollection.collectionName);

  Future<void> addEventToLocation({
    required BuildContext context,
    required String site,
    required double lat,
    required double lon,
    required String eventId,
    required String eventName,
    required String locationName,
    required String locationBanner,
    required bool public,
  }) async {
    try {
      String id = "${lat}_$lon";
      var newEvent = {
        "eventId": eventId,
        "eventName": eventName,
        "locationName": locationName,
        "locationBanner": locationBanner,
        "public": public,
      };
      var document = await FirebaseCrud.readDoc(eventLocationCollection, id);
      if (document!.exists) {
        await eventLocationCollection.doc(id).update({
          "events": FieldValue.arrayUnion([newEvent])
        });
      } else {
        eventLocationCollection.doc(id).set({
          "site": site,
          "lat": lat,
          "lon": lon,
          "events": [newEvent]
        });
      }
    } on FirebaseException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  Future<void> removeEventFromLocation({
    required BuildContext context,
    required String site,
    required double lat,
    required double lon,
    required String eventId,
    required String eventName,
    required String locationName,
    required String locationBanner,
    required bool public,
  }) async {
    try {
      String id = "${lat}_$lon";
      var oldEvent = {
        "eventId": eventId,
        "eventName": eventName,
        "locationName": locationName,
        "locationBanner": locationBanner,
        "public": public,
      };
      var document = await FirebaseCrud.readDoc(eventLocationCollection, id);
      if (document!.exists) {
        var tmp = (document.data()) as Map<String, dynamic>;
        tmp["events"] = (tmp["events"] as List).map((e) {
          e["eventId"] = e["eventId"].toString();
          e["eventName"] = e["eventName"].toString();
          e["locationName"] = e["locationName"].toString();
          e["locationBanner"] = e["locationBanner"].toString();
          e["public"] = e["public"] as bool;
          return e as Map<String, dynamic>;
        }).toList();
        EventLocationCollection eventLocationDetails =
            EventLocationCollection.fromMap(tmp);

        Map<String, dynamic>? dbEvent = eventLocationDetails.events
            .firstWhereOrNull((element) =>
                element["eventId"] == eventId &&
                element["eventName"] == eventName &&
                element["locationName"] == locationName &&
                element["locationBanner"] == locationBanner &&
                element["public"] == public);

        if (eventLocationDetails.events.isNotEmpty &&
            dbEvent != null &&
            eventLocationDetails.events.length == 1) {
          await FirebaseCrud.deleteDoc(eventLocationCollection, id);
        } else {
          await eventLocationCollection.doc(id).update({
            "events": FieldValue.arrayRemove([oldEvent])
          });
        }
      } else {
        print("doc does not exist $id");
      }
    } on FirebaseException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  Future<List<EventLocationCollection>> getEventsFromBounds({
    required BuildContext context,
    required double east,
    required double west,
    required double north,
    required double south,
  }) async {
    try {
      var locations = await eventLocationCollection
          .where('lon', isGreaterThanOrEqualTo: west)
          .where('lon', isLessThanOrEqualTo: east)
          .get();
      if (locations.docs.isNotEmpty) {
        // curUid invites
        var curUid =
            Provider.of<FirebaseUser>(context, listen: false).user!.uid;
        List<PollEventInviteCollection> curUserInvites =
            await Provider.of<FirebasePollEventInvite>(context, listen: false)
                .getInvitesFromUserId(context, curUid);
        List<String> curUserInvitesIds =
            curUserInvites.map((e) => e.pollEventId).toList();

        List<EventLocationCollection> locationsInBounds = [];
        for (var e in locations.docs) {
          var tmp = e.data() as Map<String, dynamic>;
          double lat = tmp["lat"] as double;
          // lat not in bound
          if (!(lat >= south && lat <= north)) continue;
          List<Map<String, dynamic>> eventsField = [];
          var events = (e.data() as Map<String, dynamic>)["events"] as List;
          for (var e in events) {
            String eventId = e["eventId"].toString();
            bool isPublic = e["public"];
            bool isInvited = curUserInvitesIds.contains(eventId);
            // map string to push to events
            if (isPublic || isInvited) {
              Map<String, dynamic> topush = {
                "eventId": eventId,
                "eventName": e["eventName"].toString(),
                "locationName": e["locationName"].toString(),
                "locationBanner": e["locationBanner"].toString(),
                "public": isPublic,
                "invited": isInvited,
              };
              eventsField.add(topush);
            }
          }
          if (eventsField.isNotEmpty) {
            tmp["events"] = eventsField;
            EventLocationCollection eventLocationDetails =
                EventLocationCollection.fromMap(tmp);
            locationsInBounds.add(eventLocationDetails);
          }
        }
        return locationsInBounds;
      }
    } on FirebaseException catch (e) {
      //showSnackBar(context, e.message!);
      print(e.message);
    }
    return [];
  }
}
