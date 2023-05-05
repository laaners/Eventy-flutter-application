// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/server/date_methods.dart';
import 'package:dima_app/server/firebase_event.dart';
import 'package:dima_app/server/firebase_poll_event_invite.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/firebase_vote.dart';
import 'package:dima_app/server/tables/availability.dart';
import 'package:dima_app/server/tables/poll_event_collection.dart';
import 'package:dima_app/server/tables/poll_event_invite_collection.dart';
import 'package:dima_app/server/tables/vote_date_collection.dart';
import 'package:dima_app/server/tables/vote_location_collection.dart';
import 'package:dima_app/widgets/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'firebase_crud.dart';

class FirebasePoll extends ChangeNotifier {
  final FirebaseFirestore _firestore;

  FirebasePoll(this._firestore);

  CollectionReference get pollCollection =>
      _firestore.collection(PollEventCollection.collectionName);

  Future<PollEventCollection?> createPoll({
    required BuildContext context,
    required String pollEventName,
    required String organizerUid,
    required String pollEventDesc,
    required String deadline,
    required Map<String, dynamic> dates,
    required List<Map<String, dynamic>> locations,
    required bool public,
    required bool canInvite,
    required bool isClosed,
  }) async {
    PollEventCollection poll = PollEventCollection(
      pollEventName: pollEventName,
      organizerUid: organizerUid,
      pollEventDesc: pollEventDesc,
      deadline: deadline,
      dates: dates,
      locations: locations,
      public: public,
      canInvite: canInvite,
      isClosed: isClosed,
    );
    try {
      String pollId = "${pollEventName}_$organizerUid";
      var pollExistence = await FirebaseCrud.readDoc(pollCollection, pollId);
      if (pollExistence!.exists) {
        return null;
      }
      // await pollCollection.doc(pollId).set(poll.toMap());
      var tmp = poll.toMap();
      // dates to utc
      tmp["deadline"] =
          DateFormatter.string2DateTime(DateFormatter.toUtcString(deadline));
      tmp["dates"] =
          PollEventCollection.datesToUtc(tmp["dates"] as Map<String, dynamic>);
      tmp["name_lower"] = poll.pollEventName.toLowerCase();
      await pollCollection.doc(pollId).set(tmp);
    } on FirebaseException catch (e) {
      // showSnackBar(context, e.message!);
      print(e.message!);
    }
    return poll;
  }

  Stream<DocumentSnapshot<Object?>>? getPollDataSnapshot(
    BuildContext context,
    String pollId,
  ) {
    try {
      var document = FirebaseCrud.readSnapshot(
        pollCollection,
        pollId,
      );
      return document;
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return null;
  }

  Future<PollEventCollection?> getPollData(
    BuildContext context,
    String id,
  ) async {
    try {
      var pollDataDoc = await FirebaseCrud.readDoc(pollCollection, id);
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
      tmp["dates"] = PollEventCollection.datesToLocal(
          tmp["dates"] as Map<String, dynamic>);
      PollEventCollection pollDetails = PollEventCollection.fromMap(tmp);
      return pollDetails;
    } on FirebaseException catch (e) {
      showSnackBar(context, e.message!);
    }
    return null;
  }

  Future<List<PollEventCollection>> getUserPolls(
    BuildContext context,
    String userUid,
  ) async {
    try {
      var documents =
          await pollCollection.where("organizerUid", isEqualTo: userUid).get();
      if (documents.docs.isNotEmpty) {
        List<PollEventCollection> polls = documents.docs.map((doc) {
          var tmp = doc.data() as Map<String, dynamic>;
          tmp["locations"] = (tmp["locations"] as List).map((e) {
            e["lat"] = e["lat"].toDouble();
            e["lon"] = e["lon"].toDouble();
            return e as Map<String, dynamic>;
          }).toList();
          tmp["deadline"] =
              DateFormatter.dateTime2String(tmp["deadline"].toDate());
          tmp["deadline"] = DateFormatter.toLocalString(tmp["deadline"]);
          tmp["dates"] = PollEventCollection.datesToLocal(
              tmp["dates"] as Map<String, dynamic>);
          var pollDetails = PollEventCollection.fromMap(tmp);
          return pollDetails;
        }).toList();

        // check if the deadline for one event was met, if true then update the database by deleting it (and creating corresponding an event)
        List<Future> promises = [];
        polls = polls.where((pollData) {
          String nowDate =
              DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
          // today is below deadline
          if (DateFormatter.toLocalString(pollData.deadline)
                  .compareTo(nowDate) >
              0) {
            return true;
          }
          // deadline reached, delete the poll
          String pollId = "${pollData.pollEventName}_${pollData.organizerUid}";
          promises.add(closePoll(context: context, pollId: pollId));
          return false;
        }).toList();
        await Future.wait(promises);

        return polls;
      }
      return [];
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getOtherUserPublicOrInvitedPolls(
    BuildContext context,
    String userUid,
  ) async {
    try {
      var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
      List<PollEventInviteCollection> curUserInvites =
          await Provider.of<FirebasePollEventInvite>(context, listen: false)
              .getInvitesFromUserId(context, curUid);
      List<String> curUserInvitesIds =
          curUserInvites.map((e) => e.pollEventId).toList();

      var documents =
          await pollCollection.where("organizerUid", isEqualTo: userUid).get();

      if (documents.docs.isNotEmpty) {
        List<Map<String, dynamic>> polls = documents.docs.where((doc) {
          var tmp = doc.data() as Map<String, dynamic>;
          return tmp["public"] == true || curUserInvitesIds.contains(doc.id);
        }).map((doc) {
          var tmp = doc.data() as Map<String, dynamic>;
          tmp["locations"] = (tmp["locations"] as List).map((e) {
            e["lat"] = e["lat"].toDouble();
            e["lon"] = e["lon"].toDouble();
            return e as Map<String, dynamic>;
          }).toList();
          tmp["deadline"] =
              DateFormatter.dateTime2String(tmp["deadline"].toDate());
          tmp["deadline"] = DateFormatter.toLocalString(tmp["deadline"]);
          tmp["dates"] = PollEventCollection.datesToLocal(
              tmp["dates"] as Map<String, dynamic>);
          var pollDetails = PollEventCollection.fromMap(tmp);
          bool invited = curUserInvitesIds.contains(doc.id);
          return {"pollDetails": pollDetails, "invited": invited, "id": doc.id};
        }).toList();

        // check if the deadline for one event was met, if true then update the database by deleting it (and creating corresponding an event)
        List<Future> promises = [];
        polls = polls.where((e) {
          PollEventCollection pollData =
              e["pollDetails"] as PollEventCollection;
          String nowDate =
              DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
          // today is below deadline
          if (DateFormatter.toLocalString(pollData.deadline)
                  .compareTo(nowDate) >
              0) {
            return true;
          }
          // deadline reached, delete the poll
          promises.add(closePoll(context: context, pollId: e["id"]));
          return false;
        }).toList();
        await Future.wait(promises);
        return polls;
      }
      return [];
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return [];
  }

  Future<void> closePoll({
    required BuildContext context,
    required String pollId,
  }) async {
    try {
      await FirebaseCrud.updateDoc(pollCollection, pollId, "isClosed", true);
    } on FirebaseException catch (e) {
      print(e.message!);
    }
  }

  Future<void> deletePoll({
    required BuildContext context,
    required String pollId,
  }) async {
    try {
      var document = await FirebaseCrud.readDoc(pollCollection, pollId);
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
        tmp["dates"] = PollEventCollection.datesToLocal(
            tmp["dates"] as Map<String, dynamic>);

        PollEventCollection pollData = PollEventCollection.fromMap(tmp);

        // get most voted options
        List<VoteLocationCollection> votesLocations =
            await Future.wait(pollData.locations.map((location) {
          return Provider.of<FirebaseVote>(context, listen: false)
              .getVotesLocation(context, pollId, location["name"])
              .then((value) {
            if (value != null) {
              value.votes[pollData.organizerUid] = Availability.yes;
              return value;
            } else {
              return VoteLocationCollection(
                locationName: location["name"],
                pollId: pollId,
                votes: {
                  pollData.organizerUid: Availability.yes,
                },
              );
            }
          });
        }).toList());

        List<Future<VoteDateCollection>> promises = pollData.dates.keys
            .map((date) {
              return pollData.dates[date].map((slot) {
                return Provider.of<FirebaseVote>(context, listen: false)
                    .getVotesDate(
                        context, pollId, date, slot["start"], slot["end"])
                    .then((value) {
                  if (value != null) {
                    value.votes[pollData.organizerUid] = Availability.yes;
                    return value;
                  } else {
                    return VoteDateCollection(
                      pollId: pollId,
                      date: date,
                      start: slot["start"],
                      end: slot["end"],
                      votes: {
                        pollData.organizerUid: Availability.yes,
                      },
                    );
                  }
                });
              }).toList();
            })
            .toList()
            .expand((x) => x)
            .toList()
            .cast();

        List<VoteDateCollection> votesDates = await Future.wait(promises);

        List<PollEventInviteCollection> invites =
            await Provider.of<FirebasePollEventInvite>(context, listen: false)
                .getInvitesFromPollEventId(context, pollId);

        votesLocations.sort((a, b) =>
            b.getPositiveVotes().length - a.getPositiveVotes().length);
        VoteLocationCollection eventVoteLocation = votesLocations.first;
        Map<String, dynamic> eventLocation = pollData.locations.firstWhere(
            (element) => element["name"] == eventVoteLocation.locationName);
        eventLocation["invites"] = invites.map((invite) {
          return {
            "inviteeId": invite.inviteeId,
            "vote": eventVoteLocation.votes[invite.inviteeId] ?? -1,
          };
        }).toList();

        votesDates.sort((a, b) =>
            b.getPositiveVotes().length - a.getPositiveVotes().length);
        VoteDateCollection eventVoteDate = votesDates.first;
        Map<String, String> utcInfo = VoteDateCollection.dateToUtc(
          eventVoteDate.date,
          eventVoteDate.start,
          eventVoteDate.end,
        );
        Map<String, dynamic> eventDate = {
          "date": utcInfo["date"],
          "start": utcInfo["start"],
          "end": utcInfo["end"],
          "invites": invites.map((invite) {
            return {
              "inviteeId": invite.inviteeId,
              "vote": eventVoteDate.votes[invite.inviteeId] ?? -1,
            };
          }).toList(),
        };

        // delete invites
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
                  context: context,
                  pollId: pollId,
                  locationName: location["name"],
                ))
            .toList());

        // delete dates votes
        List<Future<void>> promisesVotesDates = pollData.dates.keys
            .map((date) {
              return pollData.dates[date].map((slot) {
                return Provider.of<FirebaseVote>(context, listen: false)
                    .deleteVoteDate(
                  context: context,
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
        await FirebaseCrud.deleteDoc(pollCollection, pollId);
        showSnackBar(context, "Successfully deleted poll");
      }
    } on FirebaseException catch (e) {
      print(e.message);
      showSnackBar(context, "Error in poll deletion");
    }
  }
}
