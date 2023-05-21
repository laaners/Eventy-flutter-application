/// PollEventInviteModel is a model class that represents an invite to vote for a event's poll.
class PollEventInviteModel {
  final String pollEventId;
  final String inviteeId;

  /// Creates a PollEventInviteModel.
  PollEventInviteModel({
    required this.pollEventId,
    required this.inviteeId,
  });

  /// The name of the collection.
  static const collectionName = "poll_event_invite";

  /// Creates a copy of this PollEventInviteModel but with the given fields replaced with the new values.
  PollEventInviteModel copyWith({
    String? pollEventId,
    String? inviteeId,
  }) {
    return PollEventInviteModel(
      pollEventId: pollEventId ?? this.pollEventId,
      inviteeId: inviteeId ?? this.inviteeId,
    );
  }

  /// Converts this PollEventInviteModel to a map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pollEventId': pollEventId,
      'inviteeId': inviteeId,
    };
  }

  /// Creates a PollEventInviteModel from a map.
  factory PollEventInviteModel.fromMap(Map<String, dynamic> map) {
    return PollEventInviteModel(
      pollEventId: map['pollEventId'] as String,
      inviteeId: map['inviteeId'] as String,
    );
  }

  /// Converts this PollEventInviteModel to a JSON object.
  @override
  String toString() =>
      'PollEventInviteCollection(pollEventId: $pollEventId, inviteeId: $inviteeId)';

  /// Converts this PollEventInviteModel to a JSON object.
  @override
  bool operator ==(covariant PollEventInviteModel other) {
    if (identical(this, other)) return true;

    return other.pollEventId == pollEventId && other.inviteeId == inviteeId;
  }

  /// Converts this PollEventInviteModel to a JSON object.
  @override
  int get hashCode => pollEventId.hashCode ^ inviteeId.hashCode;
}
