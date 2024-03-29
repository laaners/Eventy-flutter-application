import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/models/availability.dart';
import 'package:dima_app/models/location.dart';
import 'package:dima_app/models/poll_event_invite_model.dart';
import 'package:dima_app/models/poll_event_model.dart';
import 'package:dima_app/models/vote_date_model.dart';
import 'package:dima_app/models/vote_location_model.dart';
import 'package:dima_app/services/date_methods.dart';
import 'package:dima_app/services/firebase_crud.dart';
import 'package:dima_app/services/firebase_poll_event.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';

class MockFirebasePollEvent extends Mock implements FirebasePollEvent {
  static String testPollId = "test poll event model_test organizer uid";
  static PollEventModel testPollEventModel = PollEventModel(
    pollEventName: "test poll event model",
    organizerUid: "test organizer uid",
    pollEventDesc: "test poll event description",
    deadline: "2023-05-15 19:30:00",
    public: false,
    canInvite: false,
    dates: {
      "2023-05-18": [
        {"start": "08:00", "end": "10:00"},
      ],
      "2023-05-20": [
        {"start": "18:00", "end": "19:00"},
      ],
    },
    locations: [
      {
        "name": "Curma",
        "lat": 45.7874248,
        "lon": 6.9730618,
        "site": "Courmayeur, Valle d'Aosta / Vallée d'Aoste, 11013, Italia",
        "icon": "location_on_outlined",
      },
      {
        "lat": 46.258603,
        "lon": 10.508662,
        "name": "ponte di legno",
        "site":
            "Ponte di Legno, Comunità montana della valle Camonica, Brescia, Lombardia, 25056, Italia",
        "icon": "location_on_outlined",
      }
    ].map((e) => Location.fromMap(e)).toList(),
    isClosed: true,
  );

  static List<PollEventInviteModel> testInvites = [
    PollEventInviteModel(
        pollEventId: testPollId, inviteeId: "test organizer uid"),
    PollEventInviteModel(pollEventId: testPollId, inviteeId: "user1"),
    PollEventInviteModel(pollEventId: testPollId, inviteeId: "user2"),
    PollEventInviteModel(pollEventId: testPollId, inviteeId: "user3"),
    PollEventInviteModel(pollEventId: testPollId, inviteeId: "user4"),
  ];

  static List<VoteLocationModel> testVotesLocations = [
    VoteLocationModel(
      pollId: testPollId,
      locationName: "Curma",
      votes: {
        'test organizer uid': Availability.yes,
        'user1': 1,
        'user2': 2,
        'user3': 0,
        'user4': -1,
      },
    ),
    VoteLocationModel(
      locationName: "ponte di legno",
      pollId: testPollId,
      votes: {
        'test organizer uid': Availability.yes,
      },
    ),
  ];

  static List<VoteDateModel> testVotesDates = [
    VoteDateModel(
      pollId: MockFirebasePollEvent.testPollId,
      date: '2023-05-18',
      start: '08:00',
      end: '10:00',
      votes: {
        'test organizer uid': Availability.yes,
        'user1': 1,
        'user2': 2,
        'user3': 0,
        'user4': -1,
      },
    ),
    VoteDateModel(
      pollId: MockFirebasePollEvent.testPollId,
      date: '2023-05-20',
      start: '18:00',
      end: '19:00',
      votes: {
        'test organizer uid': Availability.yes,
      },
    ),
  ];

  @override
  Future<void> closePoll({
    required String pollId,
    required BuildContext context,
  }) async {
    return;
  }

  @override
  Future<PollEventModel?> createPoll({
    required String pollEventName,
    required String organizerUid,
    required String pollEventDesc,
    required String deadline,
    required Map<String, dynamic> dates,
    required List<Location> locations,
    required bool public,
    required bool canInvite,
    required bool isClosed,
  }) async {
    return testPollEventModel;
  }

  @override
  Future<void> deletePollEvent({
    required BuildContext context,
    required String pollId,
  }) async {
    return;
  }

  @override
  Future<Map<String, dynamic>?> getPollDataAndInvites({
    required BuildContext context,
    required String pollEventId,
  }) async {
    return {
      "data": testPollEventModel,
      "invites": testInvites,
      "locations": testVotesLocations,
      "dates": testVotesDates,
    };
  }

  @override
  Stream<DocumentSnapshot<Object?>>? getPollDataSnapshot({
    required String pollId,
  }) {
    final firestore = FakeFirebaseFirestore();
    var tmp = testPollEventModel.toMap();
    // dates to utc
    tmp["deadline"] = DateFormatter.string2DateTime(
        DateFormatter.toUtcString(testPollEventModel.deadline));
    tmp["name_lower"] = testPollEventModel.pollEventName.toLowerCase();
    firestore.collection(PollEventModel.collectionName).add(tmp);
    firestore
        .collection(PollEventModel.collectionName)
        .doc("test pollId")
        .set(tmp);
    var document = FirebaseCrud.readSnapshot(
      firestore.collection(PollEventModel.collectionName),
      "test pollId",
    );
    return document;
  }

  @override
  Future<PollEventModel?> getPollEventData({required String id}) async {
    return testPollEventModel;
  }

  @override
  Stream<List<DocumentSnapshot<Object?>>>? getUserInvitedPollsEventsSnapshot({
    required List<String> pollEventIds,
  }) {
    final firestore = FakeFirebaseFirestore();
    var tmp = testPollEventModel.toMap();
    // dates to utc
    tmp["deadline"] = DateFormatter.string2DateTime(
        DateFormatter.toUtcString(testPollEventModel.deadline));
    tmp["name_lower"] = testPollEventModel.pollEventName.toLowerCase();
    firestore.collection(PollEventModel.collectionName).add(tmp);
    firestore
        .collection(PollEventModel.collectionName)
        .doc("test pollId")
        .set(tmp);
    var streamList = [
      firestore
          .collection(PollEventModel.collectionName)
          .doc("test pollId")
          .snapshots()
    ];
    Stream<List<DocumentSnapshot>> mergedStream =
        Rx.combineLatestList(streamList);
    return mergedStream;
  }

  @override
  Stream<QuerySnapshot<Object?>>? getUserOrganizedPollsEventsSnapshot({
    required String uid,
  }) {
    final firestore = FakeFirebaseFirestore();
    var tmp = testPollEventModel.toMap();
    // dates to utc
    tmp["deadline"] = DateFormatter.string2DateTime(
        DateFormatter.toUtcString(testPollEventModel.deadline));
    tmp["name_lower"] = testPollEventModel.pollEventName.toLowerCase();
    firestore.collection(PollEventModel.collectionName).add(tmp);
    var documents = firestore
        .collection(PollEventModel.collectionName)
        .where("organizerUid", isEqualTo: "test uid")
        .snapshots();
    return documents;
  }
}
