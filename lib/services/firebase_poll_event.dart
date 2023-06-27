// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/models/location.dart';
import 'package:dima_app/models/poll_event_invite_model.dart';
import 'package:dima_app/models/poll_event_model.dart';
import 'package:dima_app/models/vote_date_model.dart';
import 'package:dima_app/models/vote_location_model.dart';
import 'package:dima_app/services/date_methods.dart';
import 'package:dima_app/services/firebase_poll_event_invite.dart';
import 'package:dima_app/services/firebase_vote.dart';
import 'package:dima_app/widgets/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import '../models/availability.dart';
import 'firebase_crud.dart';
import 'firebase_notification.dart';

class FirebasePollEvent {
  final FirebaseFirestore _firestore;

  FirebasePollEvent(this._firestore);

  CollectionReference get pollEventCollection =>
      _firestore.collection(PollEventModel.collectionName);

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
    PollEventModel poll = PollEventModel(
      pollEventName: pollEventName,
      organizerUid: organizerUid,
      pollEventDesc: pollEventDesc,
      deadline: deadline,
      dates: dates,
      locations: locations,
      public: public,
      canInvite: canInvite,
      isClosed: false,
    );
    try {
      String pollId = "${pollEventName}_$organizerUid";
      var pollExistence =
          await FirebaseCrud.readDoc(pollEventCollection, pollId);
      if (pollExistence!.exists) {
        return null;
      }
      var tmp = poll.toMap();
      // dates to utc
      tmp["deadline"] =
          DateFormatter.string2DateTime(DateFormatter.toUtcString(deadline));
      tmp["dates"] =
          PollEventModel.datesToUtc(tmp["dates"] as Map<String, dynamic>);
      tmp["name_lower"] = poll.pollEventName.toLowerCase();
      await pollEventCollection.doc(pollId).set(tmp);
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return poll;
  }

  Future<PollEventModel?> getPollEventData({required String id}) async {
    try {
      var pollDataDoc = await FirebaseCrud.readDoc(pollEventCollection, id);
      if (!pollDataDoc!.exists) return null;
      return PollEventModel.firebaseDocToObj(
          pollDataDoc.data() as Map<String, dynamic>);
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return null;
  }

  Stream<DocumentSnapshot<Object?>>? getPollDataSnapshot({
    required String pollId,
  }) {
    try {
      var document = FirebaseCrud.readSnapshot(
        pollEventCollection,
        pollId,
      );
      return document;
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return null;
  }

  Future<Map<String, dynamic>?> getPollDataAndInvites({
    required BuildContext context,
    required String pollEventId,
  }) async {
    try {
      PollEventModel? pollData =
          await Provider.of<FirebasePollEvent>(context, listen: false)
              .getPollEventData(id: pollEventId);
      if (pollData == null) return null;

      // deadline reached, close poll
      // check if it is closed or the deadline was reached, deadline already in local
      String nowDate = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
      String localDate = pollData.deadline;
      localDate = DateFormatter.toLocalString(localDate);

      if (!pollData.isClosed && localDate.compareTo(nowDate) <= 0) {
        await Provider.of<FirebasePollEvent>(context, listen: false)
            .closePoll(pollId: pollEventId, context: context);
      }

      List<PollEventInviteModel> pollInvites =
          await Provider.of<FirebasePollEventInvite>(context, listen: false)
              .getInvitesFromPollEventId(pollEventId: pollEventId);
      if (pollInvites.isEmpty) return null;

      List<VoteLocationModel> votesLocations =
          await Future.wait(pollData.locations.map((location) {
        return Provider.of<FirebaseVote>(context, listen: false)
            .getVotesLocation(pollId: pollEventId, locationName: location.name)
            .then((value) {
          if (value != null) {
            value.votes[pollData.organizerUid] = Availability.yes;
            return value;
          } else {
            return VoteLocationModel(
              locationName: location.name,
              pollId: pollEventId,
              votes: {pollData.organizerUid: Availability.yes},
            );
          }
        });
      }).toList());

      List<Future<VoteDateModel>> promises = pollData.dates.keys
          .map((date) {
            return pollData.dates[date].map((slot) {
              return Provider.of<FirebaseVote>(context, listen: false)
                  .getVotesDate(
                pollId: pollEventId,
                date: date,
                start: slot["start"],
                end: slot["end"],
              )
                  .then((value) {
                if (value != null) {
                  value.votes[pollData.organizerUid] = Availability.yes;
                  return value;
                } else {
                  return VoteDateModel(
                    pollId: pollEventId,
                    date: date,
                    start: slot["start"],
                    end: slot["end"],
                    votes: {pollData.organizerUid: Availability.yes},
                  );
                }
              });
            }).toList();
          })
          .toList()
          .expand((x) => x)
          .toList()
          .cast();

      List<VoteDateModel> votesDates = await Future.wait(promises);
      return {
        "data": pollData,
        "invites": pollInvites,
        "locations": votesLocations,
        "dates": votesDates,
      };
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> closePoll({
    required String pollId,
    required BuildContext context,
  }) async {
    try {
      var document = await FirebaseCrud.readDoc(pollEventCollection, pollId);
      if (document!.exists) {
        PollEventModel poll = PollEventModel.firebaseDocToObj(
            document.data() as Map<String, dynamic>);

        List<PollEventInviteModel> pollInvites =
            await Provider.of<FirebasePollEventInvite>(context, listen: false)
                .getInvitesFromPollEventId(pollEventId: pollId);
        await Future.wait(pollInvites
            .map((invite) => FirebaseNotification.sendNotification(
                  pollEventId: pollId,
                  organizerUid: poll.organizerUid,
                  topic: invite.inviteeId,
                  title: "The poll ${poll.pollEventName} has been closed!",
                  body:
                      "The poll ${poll.pollEventName} has been closed, see the meeting details!",
                ))
            .toList());
        await FirebaseCrud.updateDoc(
            pollEventCollection, pollId, "isClosed", true);
      }
    } on FirebaseException catch (e) {
      print(e.message!);
    }
  }

  Future<void> deletePollEvent({
    required BuildContext context,
    required String pollId,
  }) async {
    try {
      var document = await FirebaseCrud.readDoc(pollEventCollection, pollId);
      if (document!.exists) {
        var tmp = document.data() as Map<String, dynamic>;
        tmp["locations"] = (tmp["locations"] as List).map((e) {
          e["lat"] = e["lat"].toDouble();
          e["lon"] = e["lon"].toDouble();
          return e as Map<String, dynamic>;
        }).toList();
        tmp["deadline"] =
            DateFormatter.dateTime2String(tmp["deadline"].toDate());
        tmp["deadline"] = DateFormatter.toLocalString(tmp["deadline"]);
        tmp["dates"] =
            PollEventModel.datesToLocal(tmp["dates"] as Map<String, dynamic>);

        PollEventModel pollData = PollEventModel.fromMap(tmp);

        // delete invites
        List<PollEventInviteModel> invites =
            await Provider.of<FirebasePollEventInvite>(context, listen: false)
                .getInvitesFromPollEventId(pollEventId: pollId);

        await Future.wait(invites
            .map((invite) =>
                Provider.of<FirebasePollEventInvite>(context, listen: false)
                    .deletePollEventInvite(
                  context: context,
                  pollEventId: pollId,
                  inviteeId: invite.inviteeId,
                ))
            .toList());

        // delete location votes
        await Future.wait(pollData.locations
            .map((location) => Provider.of<FirebaseVote>(context, listen: false)
                    .deleteVoteLocation(
                  pollId: pollId,
                  locationName: location.name,
                ))
            .toList());

        // delete dates votes
        List<Future<void>> promisesVotesDates = pollData.dates.keys
            .map((date) {
              return pollData.dates[date].map((slot) {
                return Provider.of<FirebaseVote>(context, listen: false)
                    .deleteVoteDate(
                  pollId: pollId,
                  date: date,
                  start: slot["start"],
                  end: slot["end"],
                );
              }).toList();
            })
            .toList()
            .expand((x) => x)
            .toList()
            .cast();
        await Future.wait(promisesVotesDates);

        // delete poll
        await FirebaseCrud.deleteDoc(pollEventCollection, pollId);
        showSnackBar(context, "Successfully deleted poll/event");
      }
    } on FirebaseException catch (e) {
      print(e.message);
      showSnackBar(context, "Error in poll/event deletion");
    }
  }

  Future<List<PollEventModel>> searchEventsByName({
    required String pattern,
  }) async {
    try {
      var events = await pollEventCollection
          .orderBy('name_lower')
          .where('name_lower', isGreaterThanOrEqualTo: pattern.toLowerCase())
          .where('name_lower', isLessThan: '${pattern.toLowerCase()}z')
          .limit(10)
          .get();
      if (events.docs.isNotEmpty) {
        List<PollEventModel> eventsData = events.docs.map((doc) {
          var tmp = doc.data() as Map<String, dynamic>;
          tmp["locations"] = (tmp["locations"] as List).map((e) {
            e["lat"] = e["lat"].toDouble();
            e["lon"] = e["lon"].toDouble();
            return e as Map<String, dynamic>;
          }).toList();
          tmp["deadline"] =
              DateFormatter.dateTime2String(tmp["deadline"].toDate());
          tmp["deadline"] = DateFormatter.toLocalString(tmp["deadline"]);
          tmp["dates"] =
              PollEventModel.datesToLocal(tmp["dates"] as Map<String, dynamic>);
          var pollDetails = PollEventModel.fromMap(tmp);
          return pollDetails;
        }).toList();
        return eventsData;
      }
    } on FirebaseException catch (e) {
      //showSnackBar(context, e.message!);
      print(e.message!);
    }
    return [];
  }

  Stream<QuerySnapshot<Object?>>? getUserOrganizedPollsEventsSnapshot({
    required String uid,
  }) {
    var documents =
        pollEventCollection.where("organizerUid", isEqualTo: uid).snapshots();
    return documents;
  }

  Stream<List<DocumentSnapshot>>? getUserInvitedPollsEventsSnapshot({
    required List<String> pollEventIds,
  }) {
    var streamList = pollEventIds.map((pollEventId) {
      return pollEventCollection.doc(pollEventId).snapshots();
    }).toList();
    Stream<List<DocumentSnapshot>> mergedStream =
        Rx.combineLatestList(streamList);
    return mergedStream;
  }

  /*
  Future<List<PollEventModel>> getUserInvitedPollsEvents({
      required List<String> pollEventIds,
    }) async {
      try {
        /*
        var documents = await pollEventCollection
            .where(FieldPath.documentId, whereIn: pollEventIds)
            .get();
        if (documents.docs.isNotEmpty) {
          final List<PollEventModel> events = documents.docs.map((doc) {
            return PollEventModel.firebaseDocToObj(
                doc.data() as Map<String, dynamic>);
          }).toList();
          return events;
          // return events.where((event) => event.isClosed).toList();
        }
        */
        List<PollEventModel?> tmp = await Future.wait(
          pollEventIds.map((e) => getPollEventData(id: e)).toList(),
        );
        List<PollEventModel> pollEvents = [];
        for (var event in tmp) {
          if (event != null) {
            pollEvents.add(event);
          }
        }
        return pollEvents;
      } on FirebaseException catch (e) {
        print(e.message!);
      }
      return [];
    }

  Future<List<PollEventModel>> getUserOrganizedPollsEvents({
    required String uid,
  }) async {
    try {
      var documents =
          await pollEventCollection.where("organizerUid", isEqualTo: uid).get();
      if (documents.docs.isNotEmpty) {
        final List<PollEventModel> events = documents.docs.map((doc) {
          return PollEventModel.firebaseDocToObj(
              doc.data() as Map<String, dynamic>);
        }).toList();
        return events;
        // return events.where((event) => event.isClosed).toList();
      }
      return [];
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return [];
  }
  */
}
