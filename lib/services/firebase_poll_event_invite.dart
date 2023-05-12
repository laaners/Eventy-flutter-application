import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/models/poll_event_invite_collection.dart';
import 'package:dima_app/services/firebase_crud.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FirebasePollEventInvite extends ChangeNotifier {
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
}
