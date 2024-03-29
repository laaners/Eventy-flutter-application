// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/models/group_model.dart';

import 'firebase_crud.dart';

class FirebaseGroups {
  final FirebaseFirestore _firestore;

  FirebaseGroups(this._firestore);

  CollectionReference get groupsCollection =>
      _firestore.collection(GroupModel.collectionName);

  Stream<QuerySnapshot<Object?>>? getUserCreatedGroupsSnapshot({
    required String uid,
  }) {
    var documents =
        groupsCollection.where("creatorUid", isEqualTo: uid).snapshots();
    return documents;
  }

  Future<GroupModel?> createGroup({
    required String uid,
    required String groupName,
    required List<String> membersUids,
  }) async {
    GroupModel group = GroupModel(
      creatorUid: uid,
      groupName: groupName,
      membersUids: membersUids,
    );
    try {
      String groupId = "${uid}_$groupName";
      var groupExistence =
          await FirebaseCrud.readDoc(groupsCollection, groupId);
      if (groupExistence!.exists) {
        return null;
      }
      Map<String, dynamic> tmp = group.toMap();
      tmp["name_lower"] = groupName.toLowerCase();
      groupsCollection.doc(groupId).set(tmp);
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return group;
  }

  Future<void> deleteGroup({
    required String uid,
    required String groupName,
  }) async {
    try {
      String groupId = "${uid}_$groupName";
      await FirebaseCrud.deleteDoc(groupsCollection, groupId);
    } on FirebaseException catch (e) {
      print(e.message!);
    }
  }
}
