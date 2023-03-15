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

  Future<PollCollection> createPoll({
    required BuildContext context,
    required String pollName,
    required String organizerUid,
    required String pollDesc,
    required String deadline,
    required Map<String, dynamic> dates,
    required List<Map<String, dynamic>> locations,
    required bool public,
  }) async {
    PollCollection poll = PollCollection(
      pollName: pollName,
      organizerUid: organizerUid,
      pollDesc: pollDesc,
      deadline: deadline,
      dates: dates,
      locations: locations,
      public: public,
    );
    try {
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
    return poll;
  }

  Future<PollCollection?> getPollData(
    BuildContext context,
    String id,
  ) async {
    try {
      var pollDataDoc = await FirebaseCrud.readDoc(pollCollection, id);
      var tmp = pollDataDoc?.data() as Map<String, dynamic>;
      tmp["locations"] = (tmp["locations"] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
      var pollDetails = PollCollection.fromMap(tmp);
      return pollDetails;
    } on FirebaseException catch (e) {
      showSnackBar(context, e.message!);
    }
    return null;
  }

  Future<List<PollCollection>> getUserPolls(
    BuildContext context,
    String userUid,
  ) async {
    try {
      var documents =
          await pollCollection.where("organizerUid", isEqualTo: userUid).get();
      print(documents.docs.toString());
      if (documents.docs.isNotEmpty) {
        final List<PollCollection> polls = documents.docs.map((doc) {
          var tmp = doc.data() as Map<String, dynamic>;
          tmp["locations"] = (tmp["locations"] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
          var pollDetails = PollCollection.fromMap(tmp);
          return pollDetails;
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
