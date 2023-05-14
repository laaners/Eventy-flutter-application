// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/models/event_location_preview.dart';
import 'package:dima_app/models/location.dart';
import 'package:dima_app/models/poll_event_invite_model.dart';
import 'package:dima_app/models/poll_event_model.dart';
import 'package:dima_app/models/vote_date_model.dart';
import 'package:dima_app/models/vote_location_model.dart';
import 'package:dima_app/services/date_methods.dart';
import 'package:dima_app/services/firebase_event_location.dart';
import 'package:dima_app/services/firebase_poll_event_invite.dart';
import 'package:dima_app/services/firebase_vote.dart';
import 'package:dima_app/widgets/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/availability.dart';
import 'firebase_crud.dart';

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

  Future<PollEventModel?> getPollData({required String id}) async {
    try {
      var pollDataDoc = await FirebaseCrud.readDoc(pollEventCollection, id);
      if (!pollDataDoc!.exists) {
        return null;
      }
      var tmp = pollDataDoc.data() as Map<String, dynamic>;
      tmp["locations"] = (tmp["locations"] as List).map((e) {
        e["lat"] = e["lat"].toDouble();
        e["lon"] = e["lon"].toDouble();
        return e as Map<String, dynamic>;
      }).toList();
      // utc string
      tmp["deadline"] = DateFormatter.dateTime2String(tmp["deadline"].toDate());
      tmp["deadline"] = DateFormatter.toLocalString(tmp["deadline"]);
      tmp["dates"] =
          PollEventModel.datesToLocal(tmp["dates"] as Map<String, dynamic>);
      PollEventModel pollDetails = PollEventModel.fromMap(tmp);
      return pollDetails;
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

  Future<void> closePoll({
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

        // get most voted location
        List<VoteLocationModel> votesLocations =
            await Future.wait(pollData.locations.map((location) {
          return Provider.of<FirebaseVote>(context, listen: false)
              .getVotesLocation(pollId: pollId, locationName: location.name)
              .then((value) {
            if (value != null) {
              value.votes[pollData.organizerUid] = Availability.yes;
              return value;
            } else {
              return VoteLocationModel(
                locationName: location.name,
                pollId: pollId,
                votes: {pollData.organizerUid: Availability.yes},
              );
            }
          });
        }).toList());

        votesLocations.sort((a, b) =>
            b.getPositiveVotes().length - a.getPositiveVotes().length);

        VoteLocationModel eventVoteLocation = votesLocations.first;
        Location eventLocation = pollData.locations.firstWhere(
          (element) => element.name == eventVoteLocation.locationName,
        );

        // get most voted date
        List<Future<VoteDateModel>> promises = pollData.dates.keys
            .map((date) {
              return pollData.dates[date].map((slot) {
                return Provider.of<FirebaseVote>(context, listen: false)
                    .getVotesDate(
                        pollId: pollId,
                        date: date,
                        start: slot["start"],
                        end: slot["end"])
                    .then((value) {
                  if (value != null) {
                    value.votes[pollData.organizerUid] = Availability.yes;
                    return value;
                  } else {
                    return VoteDateModel(
                      pollId: pollId,
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
        votesDates.sort((a, b) =>
            b.getPositiveVotes().length - a.getPositiveVotes().length);
        VoteDateModel eventVoteDate = votesDates.first;
        Map<String, String> utcInfo = VoteDateModel.dateToUtc(
          eventVoteDate.date,
          eventVoteDate.start,
          eventVoteDate.end,
        );

        List<Future<void>> updatePromises = [
          FirebaseCrud.updateDoc(pollEventCollection, pollId, "isClosed", true),
          FirebaseCrud.updateDoc(pollEventCollection, pollId, "locations",
              [eventLocation.toMap()]),
          FirebaseCrud.updateDoc(pollEventCollection, pollId, "dates", {
            utcInfo["date"]: [
              {
                "start": utcInfo["start"],
                "end": utcInfo["end"],
              }
            ]
          }),
        ];
        await Future.wait(updatePromises);
        await Provider.of<FirebaseEventLocation>(context, listen: false)
            .addEventToLocation(
          site: eventLocation.site,
          lat: eventLocation.lat,
          lon: eventLocation.lon,
          newEvent: EventLocationPreview(
            pollId,
            pollData.pollEventName,
            eventLocation.name,
            eventLocation.icon,
            utcInfo["date"]!,
            utcInfo["start"]!,
            utcInfo["end"]!,
            pollData.public,
            false, // invited field useless
          ),
        );
      }
    } on FirebaseException catch (e) {
      print(e.message!);
    }
  }

  Future<void> deletePoll({
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

  // Return the data of user whose username matches a
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
      print(e.message);
    }
    return [];
  }
}
