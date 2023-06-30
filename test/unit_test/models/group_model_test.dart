import 'package:dima_app/models/group_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final groupModel = GroupModel(
    creatorUid: 'test creator uid',
    groupName: 'test group name',
    membersUids: [
      "test member1 uid",
      "test member2 uid",
      "test member3 uid",
    ],
  );

  group('GroupModel', () {
    test('copyWith method should work correctly', () {
      final copy = groupModel.copyWith(groupName: 'another group name');
      expect(copy.groupName, 'another group name');
      expect(copy.creatorUid, 'test creator uid');
    });

    test('toMap and fromMap should work correctly', () {
      final map = groupModel.toMap();
      final fromMap = GroupModel.fromMap(map);
      expect(fromMap, groupModel);
    });

    test('toString should work correctly', () {
      expect(groupModel.toString(),
          'GroupModel(creatorUid: test creator uid, groupName: test group name, membersUids: [test member1 uid, test member2 uid, test member3 uid])');
    });

    test('Equality and hashCode should work correctly', () {
      final copy = groupModel.copyWith();
      expect(copy, groupModel);
      expect(copy.hashCode, groupModel.hashCode);
    });
  });
}
