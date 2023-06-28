// Import necessary dependencies and packages
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/show_snack_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Create mock classes for FirebaseAuth, FirebaseFirestore, and BuildContext
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockBuildContext extends Mock implements BuildContext {}

class MockFirebaseUser extends Mock implements FirebaseUser {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;

  MockFirebaseUser(this.firebaseAuth, this.firebaseFirestore);

  @override
  CollectionReference get userCollection =>
      firebaseFirestore.collection('users');

  @override
  Future<void> logInWithUsername({
    required BuildContext context,
    required String username,
    required String password,
  }) async {
    // Mock the loginWithEmail method
    await loginWithEmail(
      email: username,
      password: password,
      context: context,
    );
  }

  @override
  Future<bool> loginWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) {
    // Mock the loginWithEmail method to return a Future<bool>
    return Future.value(true);
  }
}

void main() {
  group('FirebaseUser Provider', () {
    late MockFirebaseAuth mockFirebaseAuth;
    late MockFirebaseFirestore mockFirebaseFirestore;
    late MockFirebaseUser firebaseUser;
    late MockBuildContext mockContext;

    setUp(() async {
      mockFirebaseAuth = MockFirebaseAuth();
      mockFirebaseFirestore = MockFirebaseFirestore();
      firebaseUser = MockFirebaseUser(mockFirebaseAuth, mockFirebaseFirestore);
      mockContext = MockBuildContext();
    });

    test(
        'logInWithUsername calls loginWithEmail and shows a snackbar when username exists',
        () async {
      final String username = 'Ale';
      final String password = 'password';

      // Perform the login operation
      await firebaseUser.logInWithUsername(
        context: mockContext,
        username: username,
        password: password,
      );

      // Verify that loginWithEmail was called with the correct parameters
      verify(firebaseUser.loginWithEmail(
        email: username,
        password: password,
        context: mockContext,
      )).called(1);

      // Verify that a snackbar is shown after logging in
      verify(showSnackBar(mockContext, "Welcome, $username!")).called(1);
    });
  });
}
