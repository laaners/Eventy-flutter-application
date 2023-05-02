import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/server/tables/vote_date_collection.dart';
import 'package:dima_app/server/tables/vote_location_collection.dart';
import 'package:flutter/material.dart';

import 'firebase_crud.dart';

class FirebaseVote extends ChangeNotifier {
  final FirebaseFirestore _firestore;

  FirebaseVote(this._firestore);

  CollectionReference get voteLocationCollection =>
      _firestore.collection(VoteLocationCollection.collectionName);
  CollectionReference get voteDateCollection =>
      _firestore.collection(VoteDateCollection.collectionName);

  Stream<DocumentSnapshot<Object?>>? getVoteLocationSnapshot(
    BuildContext context,
    String pollId,
    String locationName,
  ) {
    try {
      String voteId = "${pollId}_$locationName";
      var document = FirebaseCrud.readSnapshot(
        voteLocationCollection,
        voteId,
      );
      return document;
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return null;
  }

  Future<VoteLocationCollection?> getVotesLocation(
    BuildContext context,
    String pollId,
    String locationName,
  ) async {
    try {
      String voteId = "${pollId}_$locationName";
      var document = await FirebaseCrud.readDoc(
        voteLocationCollection,
        voteId,
      );
      if (!document!.exists) {
        return null;
      }
      var tmp = document.data() as Map<String, dynamic>;
      var voteLocation = VoteLocationCollection.fromMap(tmp);
      return voteLocation;
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return null;
  }

  Future<void> userVoteLocation(
    BuildContext context,
    String pollId,
    String locationName,
    String uid,
    int availability,
  ) async {
    try {
      String voteId = "${pollId}_$locationName";
      var document = await FirebaseCrud.readDoc(
        voteLocationCollection,
        voteId,
      );
      if (document!.exists) {
        await voteLocationCollection
            .doc(voteId)
            .update({"votes.$uid": availability});
      } else {
        voteLocationCollection.doc(voteId).set({
          "pollId": pollId,
          "locationName": locationName,
          "votes": {uid: availability},
        });
      }
    } on FirebaseException catch (e) {
      print(e.message!);
    }
  }

  Future<void> deleteVoteLocation({
    required BuildContext context,
    required String pollId,
    required String locationName,
  }) async {
    try {
      String voteId = "${pollId}_$locationName";
      var document = await FirebaseCrud.readDoc(
        voteLocationCollection,
        voteId,
      );
      if (document!.exists) {
        await FirebaseCrud.deleteDoc(voteLocationCollection, voteId);
      }
    } on FirebaseException catch (e) {
      // showSnackBar(context, e.message!);
      print(e.message!);
    }
  }

  Stream<DocumentSnapshot<Object?>>? getVoteDateSnapshot(
    BuildContext context,
    String pollId,
    String date,
    String start,
    String end,
  ) {
    try {
      Map<String, String> utcInfo =
          VoteDateCollection.dateToUtc(date, start, end);
      var voteId =
          "${pollId}_${utcInfo["date"]}_${utcInfo["start"]}_${utcInfo["end"]}";
      var document = FirebaseCrud.readSnapshot(
        voteDateCollection,
        voteId,
      );
      return document;
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return null;
  }

  Future<VoteDateCollection?> getVotesDate(
    BuildContext context,
    String pollId,
    String date,
    String start,
    String end,
  ) async {
    try {
      Map<String, String> utcInfo =
          VoteDateCollection.dateToUtc(date, start, end);
      var voteId =
          "${pollId}_${utcInfo["date"]}_${utcInfo["start"]}_${utcInfo["end"]}";
      var document = await FirebaseCrud.readDoc(
        voteDateCollection,
        voteId,
      );
      if (!document!.exists) {
        return null;
      }
      var tmp = document.data() as Map<String, dynamic>;
      // back to local
      tmp["date"] = date;
      tmp["start"] = start;
      tmp["end"] = end;
      var voteDate = VoteDateCollection.fromMap(tmp);
      return voteDate;
      /*
      var documents = await voteDateCollection
          .where("pollId", isEqualTo: pollId)
          .where('date', isEqualTo: date)
          .where('start', isEqualTo: start)
          .where('end', isEqualTo: end)
          .get();
      if (documents.docs.isNotEmpty) {
        final List<VoteDateCollection> votesDate = documents.docs.map((doc) {
          var tmp = doc.data() as Map<String, dynamic>;
          tmp["votes"] = (tmp["votes"] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
          var voteDate = VoteDateCollection.fromMap(tmp);
          return voteDate;
        }).toList();
        return votesDate;
      }
      return [];
       */
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return null;
  }

  Future<void> userVoteDate(
    BuildContext context,
    String pollId,
    String date,
    String start,
    String end,
    String uid,
    int availability,
  ) async {
    try {
      Map<String, String> utcInfo =
          VoteDateCollection.dateToUtc(date, start, end);
      var voteId =
          "${pollId}_${utcInfo["date"]}_${utcInfo["start"]}_${utcInfo["end"]}";
      var document = await FirebaseCrud.readDoc(
        voteDateCollection,
        voteId,
      );
      if (document!.exists) {
        await voteDateCollection
            .doc(voteId)
            .update({"votes.$uid": availability});
      } else {
        voteDateCollection.doc(voteId).set({
          "pollId": pollId,
          "date": date,
          "start": start,
          "end": end,
          "votes": {uid: availability},
        });
      }
    } on FirebaseException catch (e) {
      print(e.message!);
    }
  }

  Future<void> deleteVoteDate({
    required BuildContext context,
    required String pollId,
    required String date,
    required String start,
    required String end,
  }) async {
    try {
      Map<String, String> utcInfo =
          VoteDateCollection.dateToUtc(date, start, end);
      var voteId =
          "${pollId}_${utcInfo["date"]}_${utcInfo["start"]}_${utcInfo["end"]}";
      var document = await FirebaseCrud.readDoc(
        voteDateCollection,
        voteId,
      );
      if (document!.exists) {
        await FirebaseCrud.deleteDoc(voteDateCollection, voteId);
      }
    } on FirebaseException catch (e) {
      // showSnackBar(context, e.message!);
      print(e.message!);
    }
  }
}
