import 'package:dima_app/models/poll_event_invite_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/services/firebase_crud.dart';
import 'package:dima_app/services/firebase_poll_event_invite.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mockito/mockito.dart';

class MockFirebasePollEventInvite extends Mock
    implements FirebasePollEventInvite {
  static PollEventInviteModel testPollEventInviteModel = PollEventInviteModel(
    pollEventId: "test poll event model",
    inviteeId: 'test organizer uid',
  );

  @override
  Future<void> createPollEventInvite({
    required String pollEventId,
    required String inviteeId,
  }) async {
    return;
  }

  @override
  Future<void> deletePollEventInvite({
    required BuildContext context,
    required String pollEventId,
    required String inviteeId,
  }) async {
    return;
  }

  @override
  Stream<QuerySnapshot<Object?>>? getAllPollEventInviteSnapshot({
    required String uid,
  }) {
    String pollEventInviteId = "test poll event model_test organizer uid";
    final firestore = FakeFirebaseFirestore();
    firestore
        .collection(PollEventInviteModel.collectionName)
        .doc(pollEventInviteId)
        .set(testPollEventInviteModel.toMap());
    var documents = firestore
        .collection(PollEventInviteModel.collectionName)
        .where("inviteeId", isEqualTo: uid)
        .snapshots();
    return documents;
  }

  @override
  Future<List<PollEventInviteModel>> getInvitesFromPollEventId(
      {required String pollEventId}) async {
    return [testPollEventInviteModel];
  }

  @override
  Future<List<PollEventInviteModel>> getInvitesFromUserId(
      {required String userId}) async {
    return [testPollEventInviteModel];
  }

  @override
  Stream<DocumentSnapshot<Object?>>? getPollEventInviteSnapshot(
      {required String pollId, required String uid}) {
    String pollEventInviteId =
        "test poll event model_test organizer uid_test uid";
    final firestore = FakeFirebaseFirestore();
    firestore
        .collection(PollEventInviteModel.collectionName)
        .doc(pollEventInviteId)
        .set(testPollEventInviteModel.toMap());
    var document = FirebaseCrud.readSnapshot(
      firestore.collection(PollEventInviteModel.collectionName),
      pollEventInviteId,
    );
    return document;
  }
}
