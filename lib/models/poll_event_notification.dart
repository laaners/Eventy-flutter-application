// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dima_app/services/date_methods.dart';

class PollEventNotification {
  final String pollEventId;
  final String organizerUid;
  final String title;
  final String body;
  final bool isRead;
  final String timestamp;
  PollEventNotification({
    required this.pollEventId,
    required this.organizerUid,
    required this.title,
    required this.body,
    required this.isRead,
    required this.timestamp,
  });

  PollEventNotification copyWith({
    String? pollEventId,
    String? organizerUid,
    String? title,
    String? body,
    bool? isRead,
    String? timestamp,
  }) {
    return PollEventNotification(
      pollEventId: pollEventId ?? this.pollEventId,
      organizerUid: organizerUid ?? this.organizerUid,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pollEventId': pollEventId,
      'organizerUid': organizerUid,
      'title': title,
      'body': body,
      'isRead': isRead,
      'timestamp': timestamp,
    };
  }

  factory PollEventNotification.fromMap(Map<String, dynamic> map) {
    // to local string
    // map["timestamp"] = DateFormatter.dateTime2String(map["timestamp"].toDate());
    map["timestamp"] = DateFormatter.toLocalString(map["timestamp"]);
    return PollEventNotification(
      pollEventId: map['pollEventId'] as String,
      organizerUid: map['organizerUid'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      isRead: map['isRead'] as bool,
      timestamp: map['timestamp'] as String,
    );
  }

  @override
  String toString() {
    return 'PollEventNotification(pollEventId: $pollEventId, organizerUid: $organizerUid, title: $title, body: $body, isRead: $isRead, timestamp: $timestamp)';
  }

  @override
  bool operator ==(covariant PollEventNotification other) {
    if (identical(this, other)) return true;

    return other.pollEventId == pollEventId &&
        other.organizerUid == organizerUid &&
        other.title == title &&
        other.body == body &&
        other.isRead == isRead &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return pollEventId.hashCode ^
        organizerUid.hashCode ^
        title.hashCode ^
        body.hashCode ^
        isRead.hashCode ^
        timestamp.hashCode;
  }
}
