import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/server/tables/follow_collection.dart';
import 'package:dima_app/widgets/show_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_crud.dart';

class FirebaseFollow extends ChangeNotifier {
  final FirebaseFirestore _firestore;

  FirebaseFollow(this._firestore);

  List<String> _followersUid = [];
  List<String> _followingUid = [];

  // getters
  List<String> get followersUid => _followersUid;
  List<String> get followingUid => _followingUid;

  CollectionReference get followCollection =>
      _firestore.collection(FollowCollection.collectionName);

  Future<void> getCurrentUserFollow(String uid) async {
    var document = await FirebaseCrud.readDoc(followCollection, uid);
    if (document!.exists) {
      final follow = (document.data()) as Map<String, dynamic>?;
      _followersUid = List<String>.from(follow!["follower"]);
      _followingUid = List<String>.from(follow["following"]);
      notifyListeners();
    } else {
      _followersUid = [];
      _followingUid = [];
    }
  }

  Future<List<String>?> getFollowers(
    BuildContext context,
    String userUid,
  ) async {
    try {
      var document = await FirebaseCrud.readDoc(followCollection, userUid);
      if (document!.exists) {
        final follow = (document.data()) as Map<String, dynamic>?;
        return List<String>.from(follow!["follower"]);
      }
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return [];
  }

  Future<List<String>?> getFollowing(
    BuildContext context,
    String userUid,
  ) async {
    try {
      var document = await FirebaseCrud.readDoc(followCollection, userUid);
      if (document!.exists) {
        final follow = (document.data()) as Map<String, dynamic>?;
        return List<String>.from(follow!["following"]);
      }
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return [];
  }

  Future<void> addFollower(
    BuildContext context,
    String uid,
    String followUid, // of the followed
    bool addMutual,
  ) async {
    try {
      var document = await FirebaseCrud.readDoc(followCollection, uid);
      if (document!.exists) {
        await followCollection.doc(uid).update({
          "follower": FieldValue.arrayUnion([followUid])
        });
      } else {
        followCollection.doc(uid).set({
          "follower": [followUid],
          "following": []
        });
      }
      if (addMutual) {
        // ignore: use_build_context_synchronously
        addFollowing(context, followUid, uid, false);
      }
      // ignore: use_build_context_synchronously
      _followersUid = (await getFollowers(context, uid))!;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  Future<void> addFollowing(
    BuildContext context,
    String uid,
    String followUid,
    bool addMutual,
  ) async {
    try {
      var document = await FirebaseCrud.readDoc(followCollection, uid);
      if (document!.exists) {
        await followCollection.doc(uid).update({
          "following": FieldValue.arrayUnion([followUid])
        });
      } else {
        followCollection.doc(uid).set({
          "follower": [],
          "following": [followUid]
        });
      }
      if (addMutual) {
        // ignore: use_build_context_synchronously
        addFollower(context, followUid, uid, false);
      }
      // ignore: use_build_context_synchronously
      _followersUid = (await getFollowers(context, uid))!;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  Future<void> removeFollower(
    BuildContext context,
    String uid,
    String followUid,
    bool removeMutual,
  ) async {
    try {
      var document = await FirebaseCrud.readDoc(followCollection, uid);
      if (document!.exists) {
        await followCollection.doc(uid).update({
          "follower": FieldValue.arrayRemove([followUid])
        });
      } else {
        followCollection.doc(uid).set({
          "follower": [followUid],
          "following": []
        });
      }
      if (removeMutual) {
        // ignore: use_build_context_synchronously
        removeFollowing(context, followUid, uid, false);
      }
      // ignore: use_build_context_synchronously
      _followersUid = (await getFollowers(context, uid))!;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  Future<void> removeFollowing(
    BuildContext context,
    String uid,
    String followUid,
    bool removeMutual,
  ) async {
    try {
      var document = await FirebaseCrud.readDoc(followCollection, uid);
      if (document!.exists) {
        await followCollection.doc(uid).update({
          "following": FieldValue.arrayRemove([followUid])
        });
      } else {
        followCollection.doc(uid).set({
          "follower": [],
          "following": [followUid]
        });
      }
      if (removeMutual) {
        // ignore: use_build_context_synchronously
        removeFollower(context, followUid, uid, false);
      }
      // ignore: use_build_context_synchronously
      _followersUid = (await getFollowers(context, uid))!;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }
}
