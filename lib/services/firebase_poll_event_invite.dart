// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/models/poll_event_invite_model.dart';
import 'package:dima_app/models/poll_event_model.dart';
import 'package:dima_app/services/firebase_crud.dart';
import 'package:dima_app/services/firebase_vote.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_notification.dart';
import 'firebase_poll_event.dart';

class FirebasePollEventInvite {
  final FirebaseFirestore _firestore;

  FirebasePollEventInvite(this._firestore);

  CollectionReference get pollEventInviteCollection =>
      _firestore.collection(PollEventInviteModel.collectionName);

  Future<void> createPollEventInvite({
    required String pollEventId,
    required String inviteeId,
  }) async {
    try {
      PollEventInviteModel pollEventInvite = PollEventInviteModel(
        pollEventId: pollEventId,
        inviteeId: inviteeId,
      );
      CollectionReference pollEventCollection =
          _firestore.collection(PollEventModel.collectionName);
      var document =
          await FirebaseCrud.readDoc(pollEventCollection, pollEventId);
      if (document!.exists) {
        String pollEventInviteId = "${pollEventId}_$inviteeId";
        await pollEventInviteCollection
            .doc(pollEventInviteId)
            .set(pollEventInvite.toMap());
        PollEventModel pollEvent = PollEventModel.firebaseDocToObj(
            document.data() as Map<String, dynamic>);
        if (pollEvent.organizerUid != inviteeId) {
          await FirebaseNotification.sendNotification(
            pollEventId: pollEventId,
            organizerUid: pollEvent.organizerUid,
            topic: inviteeId,
            title: "Invitation to ${pollEvent.pollEventName}!",
            body:
                "You have been invited to partecipate to ${pollEvent.pollEventName}, see the meeting details!",
          );
        }
      }
    } on FirebaseException catch (e) {
      // showSnackBar(context, e.message!);
      print(e.message!);
    }
  }

  Future<void> deletePollEventInvite({
    required BuildContext context,
    required String pollEventId,
    required String inviteeId,
  }) async {
    try {
      String pollEventInviteId = "${pollEventId}_$inviteeId";

      // remove invitee votes on locations and dates
      PollEventModel? pollData =
          // ignore: use_build_context_synchronously
          await Provider.of<FirebasePollEvent>(context, listen: false)
              .getPollEventData(id: pollEventId);
      if (pollData == null) return;

      await Future.wait(pollData.locations.map((location) {
        return Provider.of<FirebaseVote>(context, listen: false)
            .deleteUserVoteLocation(
          pollId: pollEventId,
          locationName: location.name,
          uid: inviteeId,
        );
      }).toList());

      List<Future<void>> promises = pollData.dates.keys
          .map((date) {
            return pollData.dates[date].map((slot) {
              return Provider.of<FirebaseVote>(context, listen: false)
                  .deleteUserVoteDate(
                pollId: pollEventId,
                date: date,
                start: slot["start"],
                end: slot["end"],
                uid: inviteeId,
              );
            }).toList();
          })
          .toList()
          .expand((x) => x)
          .toList()
          .cast();
      await Future.wait(promises);
      await Future.delayed(const Duration(seconds: 1));
      await FirebaseCrud.deleteDoc(
        pollEventInviteCollection,
        pollEventInviteId,
      );
    } on FirebaseException catch (e) {
      // showSnackBar(context, e.message!);
      print(e.message!);
    }
  }

  Future<List<PollEventInviteModel>> getInvitesFromPollEventId({
    required String pollEventId,
  }) async {
    try {
      var documents = await pollEventInviteCollection
          .where("pollEventId", isEqualTo: pollEventId)
          .get();
      if (documents.docs.isNotEmpty) {
        final List<PollEventInviteModel> pollEventInvites =
            documents.docs.map((doc) {
          var tmp = doc.data() as Map<String, dynamic>;
          var pollEventInvite = PollEventInviteModel.fromMap(tmp);
          return pollEventInvite;
        }).toList();
        return pollEventInvites;
      }
      return [];
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return [];
  }

  Stream<DocumentSnapshot<Object?>>? getPollEventInviteSnapshot({
    required String pollId,
    required String uid,
  }) {
    try {
      String pollEventInviteId = "${pollId}_$uid";
      var document = FirebaseCrud.readSnapshot(
        pollEventInviteCollection,
        pollEventInviteId,
      );
      return document;
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return null;
  }

  Stream<QuerySnapshot<Object?>>? getAllPollEventInviteSnapshot({
    required String uid,
  }) {
    var documents = pollEventInviteCollection
        .where("inviteeId", isEqualTo: uid)
        .snapshots();
    return documents;
  }
}
