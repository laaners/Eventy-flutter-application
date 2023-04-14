import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/server/tables/follow_collection.dart';
import 'package:dima_app/widgets/show_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_crud.dart';

class FirebaseFollow extends ChangeNotifier {
  final FirebaseFirestore _firestore;
  final User? _user;

  FirebaseFollow(this._firestore, this._user) {
    if (_user != null) {
      getCurrentUserFollow();
    }
  }

  // List<String> _followersUid = [];
  // List<String> _followingUid = [];

  // getters
  // List<String> get followersUid => _followersUid;
  // List<String> get followingUid => _followingUid;

  CollectionReference get followCollection =>
      _firestore.collection(FollowCollection.collectionName);

  Future<FollowCollection> getCurrentUserFollow() async {
    String uid = _user!.uid;
    return await getFollow(uid);
  }

  Future<FollowCollection> getFollow(String uid) async {
    try {
      var document = await FirebaseCrud.readDoc(followCollection, uid);
      if (document!.exists) {
        var follow = (document.data()) as Map<String, dynamic>;
        return FollowCollection(
          uid: uid,
          followers:
              (follow["follower"] as List).map((e) => e as String).toList(),
          following:
              (follow["following"] as List).map((e) => e as String).toList(),
        );
      }
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return FollowCollection(
      uid: uid,
      followers: [],
      following: [],
    );
  }

  Future<List<String>> getFollowers(
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

  Future<List<String>> getFollowing(
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

  /// Add the current user [followUid] to [uid]'s follower list
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
        var follow = (document.data()) as Map<String, dynamic>;
        FollowCollection followData = FollowCollection(
          uid: uid,
          followers:
              (follow["follower"] as List).map((e) => e as String).toList(),
          following:
              (follow["following"] as List).map((e) => e as String).toList(),
        );
        if (followData.followers.isNotEmpty &&
            followData.followers.contains(followUid) &&
            followData.followers.length == 1 &&
            followData.following.isEmpty) {
          await FirebaseCrud.deleteDoc(followCollection, uid);
        } else {
          await followCollection.doc(uid).update({
            "follower": FieldValue.arrayRemove([followUid])
          });
        }
      }
      if (removeMutual) {
        // ignore: use_build_context_synchronously
        removeFollowing(context, followUid, uid, false);
      }
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
        var follow = (document.data()) as Map<String, dynamic>;
        FollowCollection followData = FollowCollection(
          uid: uid,
          followers:
              (follow["follower"] as List).map((e) => e as String).toList(),
          following:
              (follow["following"] as List).map((e) => e as String).toList(),
        );
        if (followData.following.isNotEmpty &&
            followData.following.contains(followUid) &&
            followData.following.length == 1 &&
            followData.followers.isEmpty) {
          await FirebaseCrud.deleteDoc(followCollection, uid);
        } else {
          await followCollection.doc(uid).update({
            "following": FieldValue.arrayRemove([followUid])
          });
        }
      }
      if (removeMutual) {
        // ignore: use_build_context_synchronously
        removeFollower(context, followUid, uid, false);
      }
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  /// Check if the current user [uid] is following the user [followUid]
  Future<bool> isFollowing(
    BuildContext context,
    String uid,
    String followUid,
  ) async {
    try {
      var document = await FirebaseCrud.readDoc(followCollection, uid);
      if (document!.exists) {
        var follow = (document.data()) as Map<String, dynamic>;
        FollowCollection followData = FollowCollection(
          uid: uid,
          followers:
              (follow["follower"] as List).map((e) => e as String).toList(),
          following:
              (follow["following"] as List).map((e) => e as String).toList(),
        );
        if (followData.following.contains(followUid)) {
          return true;
        }
      }
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
    return false;
  }
}
