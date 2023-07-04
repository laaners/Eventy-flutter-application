import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/models/group_model.dart';
import 'package:dima_app/services/firebase_groups.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseGroups extends Mock implements FirebaseGroups {
  static GroupModel testGroupModel = GroupModel(
    creatorUid: 'test creator uid',
    groupName: 'test group name',
    membersUids: [
      "test member1 uid",
      "test member2 uid",
      "test member3 uid",
    ],
  );

  @override
  Future<GroupModel?> createGroup({
    required String uid,
    required String groupName,
    required List<String> membersUids,
  }) async {
    return testGroupModel;
  }

  @override
  Future<void> deleteGroup({
    required String uid,
    required String groupName,
  }) async {
    return;
  }

  @override
  Future<void> editGroup(
      {required String uid,
      required String groupName,
      required List<String> membersUids}) async {
    return;
  }

  @override
  Future<List<GroupModel>> getUserCreatedGroups({
    required String uid,
  }) async {
    return [testGroupModel];
  }

  @override
  Stream<QuerySnapshot<Object?>>? getUserCreatedGroupsSnapshot({
    required String uid,
  }) {
    final firestore = FakeFirebaseFirestore();
    firestore.collection(GroupModel.collectionName).add(testGroupModel.toMap());
    var documents = firestore
        .collection(GroupModel.collectionName)
        .where("creatorUid", isEqualTo: testGroupModel.creatorUid)
        .snapshots();
    return documents;
  }
}
