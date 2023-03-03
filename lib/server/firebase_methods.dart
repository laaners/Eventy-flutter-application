import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/server/tables/follow_collection.dart';
import 'package:dima_app/server/tables/user_collection.dart';
import 'package:dima_app/widgets/show_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseMethods {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  FirebaseMethods(this._auth, this._firestore);

  // getter
  User? get user => _auth.currentUser;
  CollectionReference get userCollection =>
      _firestore.collection(UserCollection.collectionName);
  CollectionReference get followCollection =>
      _firestore.collection(FollowCollection.collectionName);

  // State persistence
  Stream<User?> get authState => _auth.authStateChanges();

  Future<void> signUpWithEmailNoVerification({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      showSnackBar(context, e.message!);
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String name,
    required String surname,
    required String profilePic,
    required BuildContext context,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // ignore: use_build_context_synchronously
      await sendEmailVerification(context);
      UserCollection userEntity = UserCollection(
        uid: userCredential.user!.uid,
        email: email,
        username: username,
        name: name,
        surname: surname,
        profilePic: profilePic,
      );
      await userCollection
          .doc(userCredential.user!.uid)
          .set(userEntity.toMap());
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  Future<void> sendEmailVerification(BuildContext context) async {
    try {
      _auth.currentUser!.sendEmailVerification();
      showSnackBar(context, "Sent email verification");
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (!_auth.currentUser!.emailVerified) {
        // ignore: use_build_context_synchronously
        await sendEmailVerification(context);
      }
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      var uid = _auth.currentUser?.uid;
      await _auth.currentUser!.delete();
      await deleteDoc(userCollection, uid!);
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  Future<void> addFollower(BuildContext context, String followUid) async {
    try {
      var uid = _auth.currentUser?.uid;
      var document = await readDoc(followCollection, uid!);
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
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  Future<void> addFollowing(BuildContext context, String followUid) async {
    try {
      var uid = _auth.currentUser?.uid;
      var document = await readDoc(followCollection, uid!);
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
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  // CRUD
  Future<void> createDoc(
    CollectionReference collection,
    String id,
  ) async {
    return null;
  }

  Future<DocumentSnapshot<Object?>?> readDoc(
    CollectionReference collection,
    String id,
  ) async {
    try {
      var uid = id;
      var document = await collection.doc(uid).get();
      return document;
    } on FirebaseAuthException catch (e) {
      print(e.message!);
    }
    return null;
  }

  Future<void> updateDoc(
    CollectionReference collection,
    String id,
    String field,
  ) async {
    try {
      await collection.doc(id).update({
        field: FieldValue.arrayUnion(['ok'])
      });
    } on FirebaseAuthException catch (e) {
      print(e.message!);
    }
  }

  Future<void> deleteDoc(
    CollectionReference collection,
    String id,
  ) async {
    try {
      await collection.doc(id).delete();
    } on FirebaseAuthException catch (e) {
      print(e.message!);
    }
  }
}
