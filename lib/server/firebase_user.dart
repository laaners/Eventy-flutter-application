// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/server/firebase_follow.dart';
import 'package:dima_app/server/firebase_poll_event.dart';
import 'package:dima_app/server/tables/user_collection.dart';
import 'package:dima_app/widgets/show_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_crud.dart';

class FirebaseUser extends ChangeNotifier {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseUser(this._auth, this._firestore);

  UserCollection? _userData;

  // getters
  User? get user => _auth.currentUser;
  UserCollection? get userData => _userData;
  CollectionReference get userCollection =>
      _firestore.collection(UserCollection.collectionName);

  // getter for
  // State persistence
  Stream<User?> get authState => _auth.authStateChanges();

  Future<UserCollection?> initUserData() async {
    try {
      var userDataDoc =
          await FirebaseCrud.readDoc(userCollection, _auth.currentUser!.uid);
      _userData = UserCollection.fromMap(
        (userDataDoc?.data()) as Map<String, dynamic>,
      );
      notifyListeners();
    } catch (e) {
      print(e);
    }
    return _userData;
  }

  Future<bool> signUpWithEmail({
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

      if (usernameValidation.docs.isNotEmpty) {
        // ignore: use_build_context_synchronously
        showSnackBar(context, "Choose another username!");
        return false;
      }

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
      Map<String, dynamic> userMap = userEntity.toMap();
      userMap["username_lower"] = username.toLowerCase();
      await userCollection.doc(userCredential.user!.uid).set(userMap);
      _userData = userEntity;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
    return false;
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
      /*
      if (!_auth.currentUser!.emailVerified) {
        // ignore: use_build_context_synchronously
        await sendEmailVerification(context);
      }
      */
      var userDataDoc =
          await FirebaseCrud.readDoc(userCollection, _auth.currentUser!.uid);
      _userData = UserCollection.fromMap(
        (userDataDoc?.data()) as Map<String, dynamic>,
      );
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  Future<void> logInWithUsername({
    required BuildContext context,
    required String username,
    required String password,
  }) async {
    try {
      var usernameValidation =
          await userCollection.where('username', isEqualTo: username).get();

      if (usernameValidation.docs.isNotEmpty) {
        String email = (usernameValidation.docs[0].data()
            as Map<String, dynamic>)['email'];
        // ignore: use_build_context_synchronously
        await loginWithEmail(
            email: email, password: password, context: context);
      } else {
        // ignore: use_build_context_synchronously
        showSnackBar(context, "Username does not exists");
      }
    } on FirebaseException catch (e) {
      print(e.message);
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      _userData = null;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  Future<bool> reauthenticationCurrentUser(
      BuildContext context, String password) async {
    try {
      loginWithEmail(
          email: userData!.email, password: password, context: context);
      return true;
    } on FirebaseException catch (e) {
      showSnackBar(context, e.message!);
    }
    return false;
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      var uid = _auth.currentUser?.uid;
      uid = "u8oRJn2HdAQP459lnSVmFxgtsW93";

      // remove from followers/following
      print("DOING: Deleting followers/following");
      Provider.of<FirebaseFollow>(context, listen: false)
          .getCurrentUserFollow()
          .then((value) async {
        await Future.wait(value.followers
            .map((followUid) =>
                Provider.of<FirebaseFollow>(context, listen: false)
                    .removeFollower(context, uid!, followUid, true))
            .toList());
        Future.wait(value.following
            .map((followUid) =>
                Provider.of<FirebaseFollow>(context, listen: false)
                    .removeFollowing(context, uid!, followUid, true))
            .toList());
      });
      print("DONE: Deleting followers/following");

      // delete associated polls
      print("DOING: Deleting associated polls");
      Provider.of<FirebasePollEvent>(context, listen: false)
          .getUserPolls(context, uid)
          .then((value) async {
        await Future.wait(value.map((pollData) {
          String pollId = "${pollData.pollEventName}_$uid";
          return Provider.of<FirebasePollEvent>(context, listen: false)
              .closePoll(context: context, pollId: pollId);
        }).toList());
      });
      print("DONE: Deleting associated polls");
      await FirebaseCrud.deleteDoc(userCollection, uid);
      notifyListeners();
      _userData = null;
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  Future<UserCollection?> getUserData(
    BuildContext context,
    String uid,
  ) async {
    try {
      var userDataDoc = await FirebaseCrud.readDoc(userCollection, uid);
      var userDetails = UserCollection.fromMap(
        userDataDoc?.data() as Map<String, dynamic>,
      );
      return userDetails;
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
    return null;
  }

  Stream<DocumentSnapshot<Object?>>? getUserDataStream(
    BuildContext context,
    String uid,
  ) {
    try {
      var document = FirebaseCrud.readSnapshot(
        userCollection,
        uid,
      );
      return document;
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return null;
  }

  // Return the data of user whose username matches a
  Future<List<UserCollection>> getUsersData(
    BuildContext context,
    String pattern,
  ) async {
    try {
      var users = await userCollection
          .orderBy('username_lower')
          .where('username_lower',
              isGreaterThanOrEqualTo: pattern.toLowerCase())
          .where('username_lower', isLessThan: '${pattern.toLowerCase()}z')
          .limit(10)
          .get();
      if (users.docs.isNotEmpty) {
        List<UserCollection> usersData = users.docs
            .map(
                (e) => UserCollection.fromMap(e.data() as Map<String, dynamic>))
            .toList();
        return usersData;
      }
    } on FirebaseException catch (e) {
      //showSnackBar(context, e.message!);
      print(e.message);
    }
    return [];
  }

  Future<List<UserCollection>> getUsersDataFromList(
      BuildContext context, List<String> uids) async {
    List<UserCollection> usersData = [];
    await Future.wait(uids.map((uid) {
      return Provider.of<FirebaseUser>(context, listen: false)
          .getUserData(context, uid)
          .then((value) {
        if (value != null) {
          return usersData.add(value);
        }
      });
    }));
    return usersData;
  }

  Future<bool> updateUserData({
    required BuildContext context,
    required String username,
    required String name,
    required String surname,
    required String email,
  }) async {
    try {
      var uid = _auth.currentUser!.uid;

      UserCollection userEntity = UserCollection(
        uid: uid,
        email: email,
        username: username,
        name: name,
        surname: surname,
        profilePic: userData!.profilePic,
      );

      Map<String, dynamic> userMap = userEntity.toMap();
      userMap["username_lower"] = username.toLowerCase();
      await userCollection.doc(uid).set(userMap);
      _userData = userEntity;

      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      showSnackBar(context, e.message!);
    }
    return false;
  }

  Future<void> updateProfilePic({
    required BuildContext context,
    required File? photo,
  }) async {
    try {
      String uid = _auth.currentUser!.uid;
      final destination = 'profile_pics/$uid';
      var ref = FirebaseStorage.instance.ref().child(destination);
      String profileUrl = "default";
      if (photo != null) {
        await ref.putFile(photo);
        profileUrl = await ref.getDownloadURL();
      }
      await FirebaseCrud.updateDoc(
          userCollection, uid, "profilePic", profileUrl);
      var tmpMap = _userData!.toMap();
      tmpMap["profilePic"] = profileUrl;
      _userData = UserCollection.fromMap(tmpMap);
      notifyListeners();
    } on FirebaseException catch (e) {
      print(e.message!);
      // showSnackBar(context, e.message!);
    }
  }

  Future<bool> usernameAlreadyExists(String username) async {
    try {
      var usernameValidation =
          await userCollection.where('username', isEqualTo: username).get();

      if (usernameValidation.docs.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } on FirebaseException catch (e) {
      print(e.message);
      return true;
    }
  }

  Future<bool> updateCurrentUserPassword(
      BuildContext context, String newPassword) async {
    try {
      await user?.updatePassword(newPassword);
      return true;
    } on FirebaseException catch (e) {
      showSnackBar(context, e.message);
    }
    return false;
  }

  Future<void> sendPasswordResetEmail(
      BuildContext context, String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      // if (e = )
      print(e.message);
    }
  }
}
