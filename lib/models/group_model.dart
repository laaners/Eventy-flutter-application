// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class GroupModel {
  final String creatorUid;
  final String groupName;
  final List<String> membersUids;
  GroupModel({
    required this.creatorUid,
    required this.groupName,
    required this.membersUids,
  });

  /// Collection name for firestore
  static const collectionName = "groups";

  GroupModel copyWith({
    String? creatorUid,
    String? groupName,
    List<String>? membersUids,
  }) {
    return GroupModel(
      creatorUid: creatorUid ?? this.creatorUid,
      groupName: groupName ?? this.groupName,
      membersUids: membersUids ?? this.membersUids,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'creatorUid': creatorUid,
      'groupName': groupName,
      'membersUids': membersUids,
    };
  }

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      creatorUid: map['creatorUid'] as String,
      groupName: map['groupName'] as String,
      membersUids: List<String>.from(map['membersUids'] as List<String>),
    );
  }

  String toJson() => json.encode(toMap());

  factory GroupModel.fromJson(String source) =>
      GroupModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'GroupModel(creatorUid: $creatorUid, groupName: $groupName, membersUids: $membersUids)';

  @override
  bool operator ==(covariant GroupModel other) {
    if (identical(this, other)) return true;

    return other.creatorUid == creatorUid &&
        other.groupName == groupName &&
        listEquals(other.membersUids, membersUids);
  }

  @override
  int get hashCode =>
      creatorUid.hashCode ^ groupName.hashCode ^ membersUids.hashCode;
}
