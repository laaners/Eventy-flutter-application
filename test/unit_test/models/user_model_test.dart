import 'package:dima_app/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final userModel = UserModel(
    uid: 'test uid',
    email: 'test email',
    username: 'test username',
    name: 'test name',
    surname: 'test surname',
    profilePic: 'test pic',
  );

  group('UserModel', () {
    test('copyWith method should work correctly', () {
      final copy = userModel.copyWith(email: 'another email');
      expect(copy.email, 'another email');
      expect(copy.uid, 'test uid');
    });

    test('toMap and fromMap should work correctly', () {
      final map = userModel.toMap();
      final fromMap = UserModel.fromMap(map);
      expect(fromMap, userModel);
    });

    test('toString should work correctly', () {
      expect(userModel.toString(),
          'UserModel(uid: test uid, email: test email, username: test username, name: test name, surname: test surname, profilePic: test pic)');
    });

    test('Equality and hashCode should work correctly', () {
      final copy = userModel.copyWith();
      expect(copy, userModel);
      expect(copy.hashCode, userModel.hashCode);
    });
  });
}
