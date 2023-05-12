import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/server/tables/poll_event_collection.dart';
import 'package:dima_app/server/tables/poll_event_invite_collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_crud.dart';
import 'firebase_poll_event.dart';
import 'firebase_vote.dart';

class FirebasePollEventInvite extends ChangeNotifier {
  final FirebaseFirestore _firestore;

  FirebasePollEventInvite(this._firestore);

  CollectionReference get pollEventInviteCollection =>
      _firestore.collection(PollEventInviteCollection.collectionName);

  Future<bool> isInvited({
    required String uid,
    required String pollEventId,
  }) async {
    try {
      String id = "${pollEventId}_$uid";
      var document = await FirebaseCrud.readDoc(pollEventInviteCollection, id);
      if (document!.exists) {
        return true;
      }
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return false;
  }

  Future<void> createPollEventInvite({
    required BuildContext context,
    required String pollEventId,
    required String inviteeId,
  }) async {
    try {
      PollEventInviteCollection pollEventInvite = PollEventInviteCollection(
        pollEventId: pollEventId,
        inviteeId: inviteeId,
      );
      String pollEventInviteId = "${pollEventId}_$inviteeId";
      var pollEventInviteExistence = await FirebaseCrud.readDoc(
          pollEventInviteCollection, pollEventInviteId);
      if (pollEventInviteExistence!.exists) {
        // ignore: use_build_context_synchronously
        // showSnackBar(context, "An invite with this name already exists");
      }
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

      PollEventCollection? pollData =
          // ignore: use_build_context_synchronously
          await Provider.of<FirebasePollEvent>(context, listen: false)
              .getPollData(context, pollEventId);
      if (pollData == null) return;

      await Future.wait(pollData.locations.map((location) {
        return Provider.of<FirebaseVote>(context, listen: false)
            .deleteUserVoteLocation(
          context: context,
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
                context: context,
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

  Future<List<PollEventInviteCollection>> getInvitesFromPollEventId(
    BuildContext context,
    String pollEventId,
  ) async {
    try {
      var documents = await pollEventInviteCollection
          .where("pollEventId", isEqualTo: pollEventId)
          .get();
      if (documents.docs.isNotEmpty) {
        final List<PollEventInviteCollection> pollEventInvites =
            documents.docs.map((doc) {
          var tmp = doc.data() as Map<String, dynamic>;
          var pollEventInvite = PollEventInviteCollection.fromMap(tmp);
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

  Future<List<PollEventInviteCollection>> getInvitesFromUserId(
    BuildContext context,
    String userId,
  ) async {
    try {
      var documents = await pollEventInviteCollection
          .where("inviteeId", isEqualTo: userId)
          .get();
      if (documents.docs.isNotEmpty) {
        final List<PollEventInviteCollection> pollEventInvites =
            documents.docs.map((doc) {
          var tmp = doc.data() as Map<String, dynamic>;
          var pollEventInvite = PollEventInviteCollection.fromMap(tmp);
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

  Stream<DocumentSnapshot<Object?>>? getPollEventInviteSnapshot(
    BuildContext context,
    String pollId,
    String uid,
  ) {
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
