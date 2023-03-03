import 'package:flutter/foundation.dart';

class FollowCollection {
  final String uid;
  final List<String> followers;
  final List<String> following;

  static const collectionName = "follow";

  FollowCollection({
    required this.uid,
    required this.followers,
    required this.following,
  });

  FollowCollection copyWith({
    String? uid,
    List<String>? followers,
    List<String>? following,
  }) {
    return FollowCollection(
      uid: uid ?? this.uid,
      followers: followers ?? this.followers,
      following: following ?? this.following,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'followers': followers,
      'following': following,
    };
  }

  factory FollowCollection.fromMap(Map<String, dynamic> map) {
    return FollowCollection(
      uid: map['uid'] as String,
      followers: List<String>.from((map['followers'] as List<String>)),
      following: List<String>.from((map['following'] as List<String>)),
    );
  }

  @override
  String toString() =>
      'FollowCollection(uid: $uid, followers: $followers, following: $following)';

  @override
  bool operator ==(covariant FollowCollection other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        listEquals(other.followers, followers) &&
        listEquals(other.following, following);
  }

  @override
  int get hashCode => uid.hashCode ^ followers.hashCode ^ following.hashCode;
}
