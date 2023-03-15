import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/server/tables/poll_event_invite_collection.dart';
import 'package:flutter/material.dart';

import 'firebase_crud.dart';

class FirebasePollEventInvite extends ChangeNotifier {
  final FirebaseFirestore _firestore;

  FirebasePollEventInvite(this._firestore);

  CollectionReference get pollEventInviteCollection =>
      _firestore.collection(PollEventInviteCollection.collectionName);

  Future<void> createPollEventInvite({
    required BuildContext context,
    required String pollId,
    required String inviteeId,
  }) async {
    try {
      PollEventInviteCollection pollEventInvite = PollEventInviteCollection(
        pollEventId: pollId,
        inviteeId: inviteeId,
      );
      String pollEventInviteId = "${pollId}_$inviteeId";
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
}
