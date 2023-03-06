import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/server/tables/poll_collection.dart';
import 'package:dima_app/widgets/show_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_crud.dart';

class FirebasePoll extends ChangeNotifier {
  final FirebaseFirestore _firestore;

  FirebasePoll(this._firestore);

  CollectionReference get pollCollection =>
      _firestore.collection(PollCollection.collectionName);

  Future<void> createPoll({
    required BuildContext context,
    required String pollName,
    required String organizerUid,
    required String pollDesc,
    required String deadline,
    required Map<String, dynamic> dates,
    required List<Map<String, dynamic>> locations,
  }) async {
    try {
      PollCollection poll = PollCollection(
        pollName: pollName,
        organizerUid: organizerUid,
        pollDesc: pollDesc,
        deadline: deadline,
        dates: dates,
        locations: locations,
      );
      String pollId = "${pollName}_$organizerUid";
      var pollExistence = await FirebaseCrud.readDoc(pollCollection, pollId);
      if (pollExistence!.exists) {
        // ignore: use_build_context_synchronously
        showSnackBar(context, "A poll with this name already exists");
      }
      await pollCollection.doc(pollId).set(poll.toMap());
    } on FirebaseAuthException catch (e) {
      // showSnackBar(context, e.message!);
      print(e.message!);
    }
  }
}
