import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/server/tables/user_collection.dart';
import 'package:dima_app/widgets/show_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_crud.dart';

class FirebaseUser extends ChangeNotifier {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseUser(this._auth, this._firestore);

  Map<String, dynamic>? _userData;

  // getters
  User? get user => _auth.currentUser;
  Map<String, dynamic>? get userData => _userData;
  CollectionReference get userCollection =>
      _firestore.collection(UserCollection.collectionName);

  // getter for
  // State persistence
  Stream<User?> get authState => _auth.authStateChanges();

  Future<Map<String, dynamic>?> initUserData() async {
    var userDataDoc =
        await FirebaseCrud.readDoc(userCollection, _auth.currentUser!.uid);
    _userData = (userDataDoc?.data()) as Map<String, dynamic>?;
    notifyListeners();
    return _userData;
  }

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

      if (usernameValidation.docs.isNotEmpty) {
        showSnackBar(context, "Choose another username!");
        return;
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
      await userCollection
          .doc(userCredential.user!.uid)
          .set(userEntity.toMap());
      _userData = userEntity.toMap();
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
      /*
      if (!_auth.currentUser!.emailVerified) {
        // ignore: use_build_context_synchronously
        await sendEmailVerification(context);
      }
      */

      var userDataDoc =
          await FirebaseCrud.readDoc(userCollection, _auth.currentUser!.uid);
      _userData = (userDataDoc?.data()) as Map<String, dynamic>?;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
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

  Future<void> deleteAccount(BuildContext context) async {
    try {
      var uid = _auth.currentUser?.uid;
      await _auth.currentUser!.delete();
      await FirebaseCrud.deleteDoc(userCollection, uid!);
      notifyListeners();
      _userData = null;
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  Future<Map<String, dynamic>?> getUserData(
    BuildContext context,
    String uid,
  ) async {
    try {
      var userDataDoc = await FirebaseCrud.readDoc(userCollection, uid);
      var userDetails = (userDataDoc?.data()) as Map<String, dynamic>?;
      return userDetails;
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
    return null;
  }

  Future<void> updateProfilePic(BuildContext context, String profileUrl) async {
    try {
      var uid = _auth.currentUser!.uid;
      await FirebaseCrud.updateDoc(
          userCollection, uid, "profilePic", profileUrl);
      _userData?["profilePic"] = profileUrl;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
    return null;
  }
}
