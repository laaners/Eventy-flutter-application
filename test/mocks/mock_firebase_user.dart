import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

class MockUser extends Mock implements User {
  @override
  String get uid {
    return "test organizer uid";
  }
}

class MockFirebaseUser extends Mock implements FirebaseUser {
  static UserModel testUserModel = UserModel(
    uid: 'test organizer uid',
    email: 'test email',
    username: 'test username',
    name: 'test name',
    surname: 'test surname',
    profilePic: 'default',
  );

  @override
  User? get user => MockUser();

  @override
  Future<UserModel?> getUserData({required String uid}) async {
    return testUserModel;
  }

  @override
  Stream<UserModel> getCurrentUserStream() {
    final future = Future.value(testUserModel);
    final stream = Stream.fromFuture(future);
    return stream;
  }

  @override
  Future<List<UserModel>> getUsersDataFromList({
    required List<String> uids,
  }) async {
    return [testUserModel];
  }

  @override
  Future<List<UserModel>> getUsersData({required String pattern}) async {
    return [
      UserModel(
        uid: 'test uid2',
        email: 'test email',
        username: 'test username',
        name: 'test name',
        surname: 'test surname',
        profilePic: 'default',
      )
    ];
  }
}
