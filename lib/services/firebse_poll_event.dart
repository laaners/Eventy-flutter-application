// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/models/location.dart';
import 'package:dima_app/models/poll_event_collection.dart';
import 'package:dima_app/services/date_methods.dart';
import 'package:dima_app/widgets/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'firebase_crud.dart';

class FirebasePollEvent {
  final FirebaseFirestore _firestore;

  FirebasePollEvent(this._firestore);

  CollectionReference get pollEventCollection =>
      _firestore.collection(PollEventModel.collectionName);

  Future<PollEventModel?> createPoll({
    required String pollEventName,
    required String organizerUid,
    required String pollEventDesc,
    required String deadline,
    required Map<String, dynamic> dates,
    required List<Location> locations,
    required bool public,
    required bool canInvite,
    required bool isClosed,
  }) async {
    PollEventModel poll = PollEventModel(
      pollEventName: pollEventName,
      organizerUid: organizerUid,
      pollEventDesc: pollEventDesc,
      deadline: deadline,
      dates: dates,
      locations: locations,
      public: public,
      canInvite: canInvite,
      isClosed: false,
    );
    try {
      String pollId = "${pollEventName}_$organizerUid";
      var pollExistence =
          await FirebaseCrud.readDoc(pollEventCollection, pollId);
      if (pollExistence!.exists) {
        return null;
      }
      var tmp = poll.toMap();
      // dates to utc
      tmp["deadline"] =
          DateFormatter.string2DateTime(DateFormatter.toUtcString(deadline));
      tmp["dates"] =
          PollEventModel.datesToUtc(tmp["dates"] as Map<String, dynamic>);
      tmp["name_lower"] = poll.pollEventName.toLowerCase();
      await pollEventCollection.doc(pollId).set(tmp);
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return poll;
  }
}
