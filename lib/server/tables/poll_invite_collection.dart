class PollInviteCollection {
  final String pollId;
  final String inviteeId;
  PollInviteCollection({
    required this.pollId,
    required this.inviteeId,
  });

  static const collectionName = "poll_invite";

  PollInviteCollection copyWith({
    String? pollId,
    String? inviteeId,
  }) {
    return PollInviteCollection(
      pollId: pollId ?? this.pollId,
      inviteeId: inviteeId ?? this.inviteeId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pollId': pollId,
      'inviteeId': inviteeId,
    };
  }

  factory PollInviteCollection.fromMap(Map<String, dynamic> map) {
    return PollInviteCollection(
      pollId: map['pollId'] as String,
      inviteeId: map['inviteeId'] as String,
    );
  }

  @override
  String toString() =>
      'PollInviteCollection(pollId: $pollId, inviteeId: $inviteeId)';

  @override
  bool operator ==(covariant PollInviteCollection other) {
    if (identical(this, other)) return true;

    return other.pollId == pollId && other.inviteeId == inviteeId;
  }

  @override
  int get hashCode => pollId.hashCode ^ inviteeId.hashCode;
}
