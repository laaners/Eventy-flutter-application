// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:dima_app/models/event_location_model.dart';
import 'package:dima_app/models/event_location_preview.dart';
import 'package:dima_app/models/poll_event_invite_model.dart';
import 'package:dima_app/services/firebase_poll_event_invite.dart';
import 'package:dima_app/widgets/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_crud.dart';
import 'firebase_user.dart';

class FirebaseEventLocation {
  final FirebaseFirestore _firestore;

  FirebaseEventLocation(this._firestore);

  CollectionReference get eventLocationCollection =>
      _firestore.collection(EventLocationModel.collectionName);

  Future<void> addEventToLocation({
    required String site,
    required double lat,
    required double lon,
    required EventLocationPreview newEvent,
  }) async {
    try {
      String id = "${lat}_$lon";
      var document = await FirebaseCrud.readDoc(eventLocationCollection, id);
      if (document!.exists) {
        await eventLocationCollection.doc(id).update({
          "events": FieldValue.arrayUnion([newEvent.toMap()])
        });
      } else {
        eventLocationCollection.doc(id).set({
          "site": site,
          "lat": lat,
          "lon": lon,
          "events": [newEvent.toMap()]
        });
      }
    } on FirebaseException catch (e) {
      print(e.message!);
    }
  }

  Future<void> removeEventFromLocation({
    required String site,
    required double lat,
    required double lon,
    required EventLocationPreview oldEvent,
  }) async {
    try {
      String id = "${lat}_$lon";
      var document = await FirebaseCrud.readDoc(eventLocationCollection, id);
      if (document!.exists) {
        var tmp = (document.data()) as Map<String, dynamic>;
        tmp["events"] = (tmp["events"] as List).map((e) {
          return EventLocationPreview.fromMap(e as Map<String, dynamic>);
        }).toList();
        EventLocationModel eventLocationDetails =
            EventLocationModel.fromMap(tmp);

        EventLocationPreview? dbEvent = eventLocationDetails.events
            .firstWhereOrNull((element) => element == oldEvent);

        if (eventLocationDetails.events.isNotEmpty &&
            dbEvent != null &&
            eventLocationDetails.events.length == 1) {
          await FirebaseCrud.deleteDoc(eventLocationCollection, id);
        } else {
          await eventLocationCollection.doc(id).update({
            "events": FieldValue.arrayRemove([oldEvent.toMap()])
          });
        }
      } else {
        print("doc does not exist $id");
      }
    } on FirebaseException catch (e) {
      print(e.message!);
    }
  }

  Future<List<EventLocationModel>> getEventsFromBounds({
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
        List<PollEventInviteModel> curUserInvites =
            await Provider.of<FirebasePollEventInvite>(context, listen: false)
                .getInvitesFromUserId(userId: curUid);
        List<String> curUserInvitesIds =
            curUserInvites.map((e) => e.pollEventId).toList();

        List<EventLocationModel> locationsInBounds = [];
        for (var e in locations.docs) {
          var tmp = e.data() as Map<String, dynamic>;
          double lat = tmp["lat"] as double;
          // lat not in bound
          if (!(lat >= south && lat <= north)) continue;
          // do not show virtual
          double lon = tmp["lon"] as double;
          if (lon == 0.0 && lat == 0.0) continue;
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
                "date": e["date"].toString(),
                "start": e["start"].toString(),
                "end": e["end"].toString(),
                "public": isPublic,
                "invited": isInvited,
              };
              eventsField.add(topush);
            }
          }
          if (eventsField.isNotEmpty) {
            tmp["events"] = eventsField;
            EventLocationModel eventLocationDetails =
                EventLocationModel.fromMap(tmp);
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
