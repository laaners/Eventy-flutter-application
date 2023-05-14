import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/models/vote_date_model.dart';
import 'package:dima_app/models/vote_location_model.dart';
import 'package:flutter/material.dart';

import 'firebase_crud.dart';

class FirebaseVote {
  final FirebaseFirestore _firestore;

  FirebaseVote(this._firestore);

  CollectionReference get voteLocationCollection =>
      _firestore.collection(VoteLocationModel.collectionName);
  CollectionReference get voteDateCollection =>
      _firestore.collection(VoteDateModel.collectionName);

  // LOCATION
  Stream<DocumentSnapshot<Object?>>? getVoteLocationSnapshot({
    required String pollId,
    required String locationName,
  }) {
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

  Future<VoteLocationModel?> getVotesLocation({
    required String pollId,
    required String locationName,
  }) async {
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
      var voteLocation = VoteLocationModel.fromMap(tmp);
      return voteLocation;
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return null;
  }

  Future<void> userVoteLocation({
    required String pollId,
    required String locationName,
    required String uid,
    required int availability,
  }) async {
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

  Future<void> deleteUserVoteLocation({
    required String pollId,
    required String locationName,
    required String uid,
  }) async {
    try {
      String voteId = "${pollId}_$locationName";
      var document = await FirebaseCrud.readDoc(
        voteLocationCollection,
        voteId,
      );
      if (document!.exists) {
        Map<String, dynamic> updatedDoc =
            document.data() as Map<String, dynamic>;
        updatedDoc["votes"].removeWhere((key, value) => key == uid);
        await voteLocationCollection
            .doc(voteId)
            .update({"votes": updatedDoc["votes"]});
      }
    } on FirebaseException catch (e) {
      print(e.message!);
    }
  }

  // DATE
  Stream<DocumentSnapshot<Object?>>? getVoteDateSnapshot({
    required String pollId,
    required String date,
    required String start,
    required String end,
  }) {
    try {
      Map<String, String> utcInfo = VoteDateModel.dateToUtc(date, start, end);
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

  Future<VoteDateModel?> getVotesDate({
    required String pollId,
    required String date,
    required String start,
    required String end,
  }) async {
    try {
      Map<String, String> utcInfo = VoteDateModel.dateToUtc(date, start, end);
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
      var voteDate = VoteDateModel.fromMap(tmp);
      return voteDate;
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return null;
  }

  Future<void> userVoteDate({
    required String pollId,
    required String date,
    required String start,
    required String end,
    required String uid,
    required int availability,
  }) async {
    try {
      Map<String, String> utcInfo = VoteDateModel.dateToUtc(date, start, end);
      var voteId =
          "${pollId}_${utcInfo["date"]}_${utcInfo["start"]}_${utcInfo["end"]}";
      var document = await FirebaseCrud.readDoc(voteDateCollection, voteId);
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
    required String pollId,
    required String date,
    required String start,
    required String end,
  }) async {
    try {
      Map<String, String> utcInfo = VoteDateModel.dateToUtc(date, start, end);
      var voteId =
          "${pollId}_${utcInfo["date"]}_${utcInfo["start"]}_${utcInfo["end"]}";
      var document = await FirebaseCrud.readDoc(voteDateCollection, voteId);
      if (document!.exists) {
        await FirebaseCrud.deleteDoc(voteDateCollection, voteId);
      }
    } on FirebaseException catch (e) {
      // showSnackBar(context, e.message!);
      print(e.message!);
    }
  }

  Future<void> deleteUserVoteDate({
    required String pollId,
    required String date,
    required String start,
    required String end,
    required String uid,
  }) async {
    try {
      Map<String, String> utcInfo = VoteDateModel.dateToUtc(date, start, end);
      var voteId =
          "${pollId}_${utcInfo["date"]}_${utcInfo["start"]}_${utcInfo["end"]}";
      var document = await FirebaseCrud.readDoc(voteDateCollection, voteId);
      if (document!.exists) {
        Map<String, dynamic> updatedDoc =
            document.data() as Map<String, dynamic>;
        updatedDoc["votes"].removeWhere((key, value) => key == uid);
        await voteDateCollection
            .doc(voteId)
            .update({"votes": updatedDoc["votes"]});
      }
    } on FirebaseException catch (e) {
      print(e.message!);
    }
  }
}
