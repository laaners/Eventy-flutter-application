import 'package:dima_app/models/vote_location_model.dart';
import 'package:dima_app/models/vote_date_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/services/firebase_crud.dart';
import 'package:dima_app/services/firebase_vote.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mockito/mockito.dart';

import 'mock_firebase_poll_event.dart';

class MockFirebaseVote extends Mock implements FirebaseVote {
  static VoteDateModel testVoteDate = VoteDateModel(
    pollId: MockFirebasePollEvent.testPollId,
    date: '2023-05-18',
    start: '08:00',
    end: '10:00',
    votes: {
      'user1': 1,
      'user2': 2,
      'user3': 0,
      'user4': -1,
    },
  );

  static VoteLocationModel testVoteLocation = VoteLocationModel(
    pollId: MockFirebasePollEvent.testPollId,
    locationName: "Curma",
    votes: {
      'user1': 1,
      'user2': 2,
      'user3': 0,
      'user4': -1,
    },
  );

  @override
  Stream<DocumentSnapshot<Object?>>? getVoteDateSnapshot({
    required String pollId,
    required String date,
    required String start,
    required String end,
  }) {
    final firestore = FakeFirebaseFirestore();
    firestore
        .collection(VoteDateModel.collectionName)
        .doc("date id")
        .set(testVoteDate.toMap());
    var document = FirebaseCrud.readSnapshot(
      firestore.collection(VoteDateModel.collectionName),
      "date id",
    );
    return document;
  }

  @override
  Stream<DocumentSnapshot<Object?>>? getVoteLocationSnapshot(
      {required String pollId, required String locationName}) {
    final firestore = FakeFirebaseFirestore();
    firestore
        .collection(VoteLocationModel.collectionName)
        .doc("location id")
        .set(testVoteLocation.toMap());
    var document = FirebaseCrud.readSnapshot(
      firestore.collection(VoteLocationModel.collectionName),
      "location id",
    );
    return document;
  }
}
