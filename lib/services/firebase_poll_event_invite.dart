import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/models/poll_event_invite_model.dart';
import 'package:dima_app/models/poll_event_model.dart';
import 'package:dima_app/services/firebase_crud.dart';
import 'package:dima_app/services/firebase_vote.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      String pollEventInviteId = "${pollEventId}_$inviteeId";
      /*
      var pollEventInviteExistence = await FirebaseCrud.readDoc(
          pollEventInviteCollection, pollEventInviteId);
      if (pollEventInviteExistence!.exists) {
        // ignore: use_build_context_synchronously
        // showSnackBar(context, "An invite with this name already exists");
      }
      */
      await pollEventInviteCollection
          .doc(pollEventInviteId)
          .set(pollEventInvite.toMap());
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
      await FirebaseCrud.deleteDoc(
        pollEventInviteCollection,
        pollEventInviteId,
      );

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

  Future<List<PollEventInviteModel>> getInvitesFromUserId({
    required String userId,
  }) async {
    try {
      var documents = await pollEventInviteCollection
          .where("inviteeId", isEqualTo: userId)
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
}
