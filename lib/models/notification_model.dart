// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'poll_event_notification.dart';

class NotificationModel {
  final List<PollEventNotification> notifications;
  NotificationModel({
    required this.notifications,
  });
  static const collectionName = "notification";

  NotificationModel copyWith({
    List<PollEventNotification>? notifications,
  }) {
    return NotificationModel(
      notifications: notifications ?? this.notifications,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'notifications': notifications.map((x) => x.toMap()).toList(),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      notifications: List<PollEventNotification>.from(
        (map['notifications'] as List<dynamic>).map<PollEventNotification>(
          (x) => PollEventNotification.fromMap(x),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationModel.fromJson(String source) =>
      NotificationModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'NotificationModel(notifications: $notifications)';

  @override
  bool operator ==(covariant NotificationModel other) {
    if (identical(this, other)) return true;

    return listEquals(other.notifications, notifications);
  }

  @override
  int get hashCode => notifications.hashCode;
}
