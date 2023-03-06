import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/server/tables/follow_collection.dart';
import 'package:dima_app/server/tables/poll_collection.dart';
import 'package:dima_app/server/tables/user_collection.dart';
import 'package:dima_app/widgets/show_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseMethods extends ChangeNotifier {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  FirebaseMethods(this._auth, this._firestore);

  // loader

  // getter
  User? get user => _auth.currentUser;

  // get collections/firestore entities
  CollectionReference get userCollection =>
      _firestore.collection(UserCollection.collectionName);
  CollectionReference get followCollection =>
      _firestore.collection(FollowCollection.collectionName);
  CollectionReference get pollCollection =>
      _firestore.collection(PollCollection.collectionName);

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
      var usernameValidation =
          await userCollection.where('username', isEqualTo: username).get();

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // ignore: use_build_context_synchronously
      // await sendEmailVerification(context);
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
      notifyListeners();
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
      var uid = _auth.currentUser?.uid;
      var document = await readDoc(userCollection, uid!);
      print(document);

      notifyListeners();

      /*
      if (!_auth.currentUser!.emailVerified) {
        // ignore: use_build_context_synchronously
        await sendEmailVerification(context);
      }
      */
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      var uid = _auth.currentUser?.uid;
      await _auth.currentUser!.delete();
      await deleteDoc(userCollection, uid!);
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  Future<void> addFollower(
    BuildContext context,
    String uid,
    String followUid,
  ) async {
    try {
      var document = await readDoc(followCollection, uid);
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

  Future<void> addFollowing(
    BuildContext context,
    String uid,
    String followUid,
  ) async {
    try {
      var document = await readDoc(followCollection, uid);
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

  Future<void> createPoll({
    required BuildContext context,
    required String pollName,
    required String organizerUid,
    required String pollDesc,
    required String deadline,
    required Map<String, dynamic> dates,
    required List<Map<String, dynamic>> locations,
  }) async {
    try {
      PollCollection poll = PollCollection(
        pollName: pollName,
        organizerUid: organizerUid,
        pollDesc: pollDesc,
        deadline: deadline,
        dates: dates,
        locations: locations,
      );
      String pollId = "${pollName}_$organizerUid";
      var pollExistence = await readDoc(pollCollection, pollId);
      if (pollExistence!.exists) {
        // ignore: use_build_context_synchronously
        showSnackBar(context, "A poll with this name already exists");
      }
      await pollCollection.doc(pollId).set(poll.toMap());
    } on FirebaseAuthException catch (e) {
      // showSnackBar(context, e.message!);
      print(e.message!);
    }
  }

  // CRUD
  Future<Stream<DocumentSnapshot<Object?>>?> readSnapshot(
    CollectionReference collection,
    String id,
  ) async {
    try {
      var document = collection.doc(id).snapshots();
      return document;
    } on FirebaseAuthException catch (e) {
      print(e.message!);
    }
    return null;
  }

  Future<DocumentSnapshot<Object?>?> readDoc(
    CollectionReference collection,
    String id,
  ) async {
    try {
      var document = await collection.doc(id).get();
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
