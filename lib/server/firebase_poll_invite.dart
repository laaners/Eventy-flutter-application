import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/server/tables/poll_invite_collection.dart';
import 'package:dima_app/widgets/show_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_crud.dart';

class FirebasePollInvite extends ChangeNotifier {
  final FirebaseFirestore _firestore;

  FirebasePollInvite(this._firestore);

  CollectionReference get pollInviteCollection =>
      _firestore.collection(PollInviteCollection.collectionName);

  Future<void> createPollInvite({
    required BuildContext context,
    required String pollId,
    required String inviteeId,
  }) async {
    try {
      PollInviteCollection pollInvite = PollInviteCollection(
        pollId: pollId,
        inviteeId: inviteeId,
      );
      String pollInviteId = "${pollId}_$inviteeId";
      var pollInviteExistence =
          await FirebaseCrud.readDoc(pollInviteCollection, pollInviteId);
      if (pollInviteExistence!.exists) {
        // ignore: use_build_context_synchronously
        // showSnackBar(context, "An invite with this name already exists");
      }
      await pollInviteCollection.doc(pollInviteId).set(pollInvite.toMap());
    } on FirebaseException catch (e) {
      // showSnackBar(context, e.message!);
      print(e.message!);
    }
  }
}
