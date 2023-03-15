class PollEventInviteCollection {
  final String pollEventId;
  final String inviteeId;
  PollEventInviteCollection({
    required this.pollEventId,
    required this.inviteeId,
  });

  static const collectionName = "poll_event_invite";

  PollEventInviteCollection copyWith({
    String? pollEventId,
    String? inviteeId,
  }) {
    return PollEventInviteCollection(
      pollEventId: pollEventId ?? this.pollEventId,
      inviteeId: inviteeId ?? this.inviteeId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pollEventId': pollEventId,
      'inviteeId': inviteeId,
    };
  }

  factory PollEventInviteCollection.fromMap(Map<String, dynamic> map) {
    return PollEventInviteCollection(
      pollEventId: map['pollEventId'] as String,
      inviteeId: map['inviteeId'] as String,
    );
  }

  @override
  String toString() =>
      'PollEventInviteCollection(pollEventId: $pollEventId, inviteeId: $inviteeId)';

  @override
  bool operator ==(covariant PollEventInviteCollection other) {
    if (identical(this, other)) return true;

    return other.pollEventId == pollEventId && other.inviteeId == inviteeId;
  }

  @override
  int get hashCode => pollEventId.hashCode ^ inviteeId.hashCode;
}
