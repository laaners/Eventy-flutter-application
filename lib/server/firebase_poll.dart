import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/server/date_methods.dart';
import 'package:dima_app/server/firebase_poll_event_invite.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/tables/poll_collection.dart';
import 'package:dima_app/server/tables/poll_event_invite_collection.dart';
import 'package:dima_app/widgets/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_crud.dart';

class FirebasePoll extends ChangeNotifier {
  final FirebaseFirestore _firestore;

  FirebasePoll(this._firestore);

  CollectionReference get pollCollection =>
      _firestore.collection(PollCollection.collectionName);

  Future<PollCollection?> createPoll({
    required BuildContext context,
    required String pollName,
    required String organizerUid,
    required String pollDesc,
    required String deadline,
    required Map<String, dynamic> dates,
    required List<Map<String, dynamic>> locations,
    required bool public,
    required bool canInvite,
  }) async {
    PollCollection poll = PollCollection(
      pollName: pollName,
      organizerUid: organizerUid,
      pollDesc: pollDesc,
      deadline: deadline,
      dates: dates,
      locations: locations,
      public: public,
      canInvite: canInvite,
    );
    try {
      String pollId = "${pollName}_$organizerUid";
      var pollExistence = await FirebaseCrud.readDoc(pollCollection, pollId);
      if (pollExistence!.exists) {
        // ignore: use_build_context_synchronously
        /// showSnackBar(context, "A poll with this name already exists");
        // ignore: use_build_context_synchronously
        return null;
      }

      // await pollCollection.doc(pollId).set(poll.toMap());
      var test = poll.toMap();
      // deadline in utc
      test["deadline"] = DateFormatter.string2DateTime(deadline);
      await pollCollection.doc(pollId).set(test);
    } on FirebaseException catch (e) {
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
      if (!pollDataDoc!.exists) {
        return null;
      }
      var tmp = pollDataDoc.data() as Map<String, dynamic>;
      tmp["locations"] = (tmp["locations"] as List).map((e) {
        e["lat"] = e["lat"].toDouble();
        e["lon"] = e["lon"].toDouble();
        return e as Map<String, dynamic>;
      }).toList();
      // utc string
      tmp["deadline"] = DateFormatter.dateTime2String(tmp["deadline"].toDate());
      tmp["deadline"] = DateFormatter.toLocalString(tmp["deadline"]);
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
      if (documents.docs.isNotEmpty) {
        final List<PollCollection> polls = documents.docs.map((doc) {
          var tmp = doc.data() as Map<String, dynamic>;
          tmp["locations"] = (tmp["locations"] as List).map((e) {
            e["lat"] = e["lat"].toDouble();
            e["lon"] = e["lon"].toDouble();
            return e as Map<String, dynamic>;
          }).toList();
          tmp["deadline"] =
              DateFormatter.dateTime2String(tmp["deadline"].toDate());
          tmp["deadline"] = DateFormatter.toLocalString(tmp["deadline"]);
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

  Future<List<Map<String, dynamic>>> getOtherUserPublicOrInvitedPolls(
    BuildContext context,
    String userUid,
  ) async {
    try {
      var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
      List<PollEventInviteCollection> curUserInvites =
          await Provider.of<FirebasePollEventInvite>(context, listen: false)
              .getInvitesFromUserId(context, curUid);
      List<String> curUserInvitesIds =
          curUserInvites.map((e) => e.pollEventId).toList();

      var documents =
          await pollCollection.where("organizerUid", isEqualTo: userUid).get();

      if (documents.docs.isNotEmpty) {
        final List<Map<String, dynamic>> polls = documents.docs.where((doc) {
          var tmp = doc.data() as Map<String, dynamic>;
          return tmp["public"] == true || curUserInvitesIds.contains(doc.id);
        }).map((doc) {
          var tmp = doc.data() as Map<String, dynamic>;
          tmp["locations"] = (tmp["locations"] as List).map((e) {
            e["lat"] = e["lat"].toDouble();
            e["lon"] = e["lon"].toDouble();
            return e as Map<String, dynamic>;
          }).toList();
          tmp["deadline"] =
              DateFormatter.dateTime2String(tmp["deadline"].toDate());
          tmp["deadline"] = DateFormatter.toLocalString(tmp["deadline"]);
          var pollDetails = PollCollection.fromMap(tmp);
          bool invited = curUserInvitesIds.contains(doc.id);
          return {"pollDetails": pollDetails, "invited": invited};
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
