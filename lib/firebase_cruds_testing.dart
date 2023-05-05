import 'dart:math';

import 'package:dima_app/server/firebase_event.dart';
import 'package:dima_app/server/firebase_follow.dart';
import 'package:dima_app/server/firebase_poll_event.dart';
import 'package:dima_app/server/firebase_poll_event_invite.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/firebase_vote.dart';
import 'package:dima_app/server/tables/user_collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FirebaseCrudsTesting {
  static List<int> someIds = [
    80143954,
    62892347,
    88190790,
    53701259,
    51706604,
    88305705,
    54828837,
    46796664,
    19302550,
    62587693,
    32134638,
    368382,
    38988538,
    63251695,
    77153811,
    83274244,
    19162134,
    93449450,
    64211118,
    79868386,
    27104921,
    73551138,
    25924653,
  ];

  static List<Map<String, dynamic>> someLocations = [
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
    },
    {
      "lat": 45.4926642,
      "lon": 9.1928945,
      "name": "casa",
      "site": "Viale Zara",
      "icon": "home_outlined",
    },
    {
      "lat": 45.4789256,
      "lon": 9.2257514,
      "name": "polimi",
      "site": "Piazza Leonardo Da Vinci - Politecnico",
      "icon": "school_outlined",
    }
  ];

  static void signUpNewUsers(BuildContext context) async {
    for (int i = 0; i < someIds.length; i++) {
      int id = someIds[i];
      await Provider.of<FirebaseUser>(context, listen: false).signUpWithEmail(
        email: "$id@nonexistent.com",
        password: "password",
        username: i % 2 == 0 ? "UsernameId$i" : "usernameId$i",
        name: "NameId$i",
        surname: "SurnameId$i",
        profilePic:
            "https://images.ygoprodeck.com/images/cards_cropped/$id.jpg",
        context: context,
      );
      // ignore: use_build_context_synchronously
      await Provider.of<FirebaseUser>(context, listen: false).signOut(context);
      // ignore: use_build_context_synchronously
    }
  }

  static void createFollowingFollowers(BuildContext context) async {
    final random = Random();
    List<UserCollection> users =
        await Provider.of<FirebaseUser>(context, listen: false)
            .getUsersData(context, "username");
    int next(int min, int max) => min + random.nextInt(max - min);
    for (int i = 0; i < users.length; i++) {
      int followings = next(0, users.length);
      for (int j = 0; j < followings; j++) {
        // random followers
        String uid = users[i].uid;
        String followUid = users[next(0, users.length)].uid;
        if (uid != followUid) {
          // ignore: use_build_context_synchronously
          await Provider.of<FirebaseFollow>(context, listen: false)
              .addFollowing(context, uid, followUid, true);
        }
      }
    }
  }

  static void createPolls(BuildContext context) async {
    final random = Random();
    List<UserCollection> users =
        await Provider.of<FirebaseUser>(context, listen: false)
            .getUsersData(context, "username");
    int next(int min, int max) => min + random.nextInt(max - min);
    for (int i = 0; i < users.length; i++) {
      String organizerUid = users[i].uid;
      int numPolls = next(0, 5);
      for (int j = 0; j < numPolls; j++) {
        String eventName = "Event $j of ${users[i].username}";
        List<Map<String, dynamic>> locations = j % 2 == 0
            ? [
                {
                  "name": "Virtual meeting",
                  "lat": 0,
                  "lon": 0,
                  "site": "",
                  "icon": "videocam",
                }
              ]
            : [];
        int randomLocation1 = next(0, someLocations.length);
        int randomLocation2 = next(0, someLocations.length);
        locations.add(someLocations[randomLocation1]);
        if (randomLocation1 != randomLocation2) {
          locations.add(someLocations[randomLocation2]);
        }

        int tmp = next(4, 12);
        String deadlineM = tmp < 10 ? "0$tmp" : "$tmp";
        tmp = next(1, 15);
        String deadlineD = tmp < 10 ? "0$tmp" : "$tmp";

        Map<String, dynamic> localDates = {
          "2023-$deadlineM-${tmp + 1 < 10 ? "0${tmp + 1}" : "${tmp + 1}"}": {
            "17:10-18:30": 1
          }
        };

        '{2023-05-19 00:00:00: {12:20-13:20: 1}, 2023-05-18 00:00:00: {12:20-13:20: 1, 12:25-13:20: 1}}';

        int numDates = next(0, 15);
        for (int k = 2; k < numDates; k++) {
          String date =
              "2023-$deadlineM-${tmp + k < 10 ? "0${tmp + k}" : "${tmp + k}"}";
          localDates[date] = k % 3 == 0 ? {"17:10-18:30": 1} : {};
          int numSlots = next(1, 4);
          for (int h = 0; h < numSlots; h++) {
            int start = 8 + 1 + h;
            int end = start + 1;
            localDates[date][
                "${start < 10 ? "0$start" : "$start"}:00-${end < 10 ? "0$end" : "$end"}:${next(1, 5) * 10}"] = 1;
          }
        }

        /*
        {pollName: j, organizerUid: u8oRJn2HdAQP459lnSVmFxgtsW93, pollDesc: , deadline: 2023-03-26 22:00:00, dates: {2023-03-31: [{start: 15:00, end: 16:00}]}, locations: [{name: Virtual meeting, site: , lat: 0.0, lon: 0.0}], public: true}
        */
        // ignore: use_build_context_synchronously
        print(localDates);
        print(locations);
        // ignore: use_build_context_synchronously
        await Provider.of<FirebasePollEvent>(context, listen: false).createPoll(
          context: context,
          pollEventName: eventName,
          organizerUid: organizerUid,
          pollEventDesc: j % 2 == 0 ? "" : "Some random desc for event $j",
          deadline: "2023-$deadlineM-$deadlineD 21:30:00",
          dates: localDates as Map<String, dynamic>,
          locations: locations as List<Map<String, dynamic>>,
          public: next(0, 2) % 2 == 0,
          canInvite: next(0, 2) % 2 == 0,
          isClosed: false,
        );

        String pollId = "${eventName}_$organizerUid";
        // ignore: use_build_context_synchronously
        await Provider.of<FirebasePollEventInvite>(context, listen: false)
            .createPollEventInvite(
          context: context,
          pollEventId: pollId,
          inviteeId: organizerUid,
        );
        print("Created a poll");

        // create invites
        List<String> invitesIds = [];
        int invites = next(0, users.length);
        for (int j = 0; j < invites; j++) {
          // random invites
          String inviteeUid = users[next(0, users.length)].uid;
          if (inviteeUid != organizerUid) {
            // ignore: use_build_context_synchronously
            await Provider.of<FirebasePollEventInvite>(context, listen: false)
                .createPollEventInvite(
              context: context,
              pollEventId: pollId,
              inviteeId: inviteeUid,
            );
            invitesIds.add(inviteeUid);
          }
        }

        // random votes
        for (String uid in invitesIds) {
          for (int k = 0; k < locations.length; k++) {
            // ignore: use_build_context_synchronously
            await Provider.of<FirebaseVote>(context, listen: false)
                .userVoteLocation(
              context,
              pollId,
              locations[k]["name"],
              uid,
              next(-1, 3),
            );
          }
          for (var day in localDates.keys) {
            for (var slot in localDates[day].keys) {
              // ignore: use_build_context_synchronously
              await Provider.of<FirebaseVote>(context, listen: false)
                  .userVoteDate(
                context,
                pollId,
                day.split(" ")[0],
                "${slot.split("-")[0]}",
                "${slot.split("-")[1]}",
                uid,
                next(-1, 3),
              );
            }
          }
          print("added");
        }
      }
    }
    print("Created all");
  }

  static void createExpiredPolls(BuildContext context) async {
    final random = Random();
    List<UserCollection> users =
        await Provider.of<FirebaseUser>(context, listen: false)
            .getUsersData(context, "username");
    int next(int min, int max) => min + random.nextInt(max - min);
    for (int i = 0; i < users.length; i++) {
      String organizerUid = users[i].uid;
      int numPolls = next(0, 5);
      for (int j = 0; j < numPolls; j++) {
        String eventName = "Fixed event $j of ${users[i].username}";
        List<Map<String, dynamic>> locations = [];
        int randomLocation1 = next(0, someLocations.length);
        int randomLocation2 = next(0, someLocations.length);
        locations.add(someLocations[randomLocation1]);
        if (randomLocation1 != randomLocation2) {
          locations.add(someLocations[randomLocation2]);
        }

        int tmp = next(4, 12);
        String deadlineM = tmp < 10 ? "0$tmp" : "$tmp";
        deadlineM = "04";
        tmp = next(1, 15);
        String deadlineD = tmp < 10 ? "0$tmp" : "$tmp";

        Map<String, dynamic> localDates = {
          "2023-$deadlineM-${tmp + 1 < 10 ? "0${tmp + 1}" : "${tmp + 1}"}": {
            "17:10-18:30": 1
          }
        };

        '{2023-05-19 00:00:00: {12:20-13:20: 1}, 2023-05-18 00:00:00: {12:20-13:20: 1, 12:25-13:20: 1}}';

        int numDates = next(0, 15);
        for (int k = 2; k < numDates; k++) {
          String date =
              "2023-$deadlineM-${tmp + k < 10 ? "0${tmp + k}" : "${tmp + k}"}";
          localDates[date] = k % 3 == 0 ? {"17:10-18:30": 1} : {};
          int numSlots = next(1, 4);
          for (int h = 0; h < numSlots; h++) {
            int start = 8 + 1 + h;
            int end = start + 1;
            localDates[date][
                "${start < 10 ? "0$start" : "$start"}:00-${end < 10 ? "0$end" : "$end"}:${next(1, 5) * 10}"] = 1;
          }
        }

        /*
        {pollName: j, organizerUid: u8oRJn2HdAQP459lnSVmFxgtsW93, pollDesc: , deadline: 2023-03-26 22:00:00, dates: {2023-03-31: [{start: 15:00, end: 16:00}]}, locations: [{name: Virtual meeting, site: , lat: 0.0, lon: 0.0}], public: true}
        */
        // ignore: use_build_context_synchronously
        print(localDates);
        print(locations);
        // ignore: use_build_context_synchronously
        await Provider.of<FirebasePollEvent>(context, listen: false).createPoll(
          context: context,
          pollEventName: eventName,
          organizerUid: organizerUid,
          pollEventDesc: j % 2 == 0 ? "" : "Some random desc for event $j",
          deadline: "2023-$deadlineM-$deadlineD 21:30:00",
          dates: localDates as Map<String, dynamic>,
          locations: locations as List<Map<String, dynamic>>,
          public: next(0, 2) % 2 == 0,
          canInvite: next(0, 2) % 2 == 0,
          isClosed: false,
        );

        String pollId = "${eventName}_$organizerUid";
        // ignore: use_build_context_synchronously
        await Provider.of<FirebasePollEventInvite>(context, listen: false)
            .createPollEventInvite(
          context: context,
          pollEventId: pollId,
          inviteeId: organizerUid,
        );
        print("Created a poll");

        // create invites
        List<String> invitesIds = [];
        int invites = next(0, users.length);
        for (int j = 0; j < invites; j++) {
          // random invites
          String inviteeUid = users[next(0, users.length)].uid;
          if (inviteeUid != organizerUid) {
            // ignore: use_build_context_synchronously
            await Provider.of<FirebasePollEventInvite>(context, listen: false)
                .createPollEventInvite(
              context: context,
              pollEventId: pollId,
              inviteeId: inviteeUid,
            );
            invitesIds.add(inviteeUid);
          }
        }

        // random votes
        for (String uid in invitesIds) {
          for (int k = 0; k < locations.length; k++) {
            // ignore: use_build_context_synchronously
            await Provider.of<FirebaseVote>(context, listen: false)
                .userVoteLocation(
              context,
              pollId,
              locations[k]["name"],
              uid,
              next(-1, 3),
            );
          }
          for (var day in localDates.keys) {
            for (var slot in localDates[day].keys) {
              // ignore: use_build_context_synchronously
              await Provider.of<FirebaseVote>(context, listen: false)
                  .userVoteDate(
                context,
                pollId,
                day.split(" ")[0],
                "${slot.split("-")[0]}",
                "${slot.split("-")[1]}",
                uid,
                next(-1, 3),
              );
            }
          }
        }

        // close0
        // ignore: use_build_context_synchronously
        await Provider.of<FirebasePollEvent>(context, listen: false)
            .closePoll(context: context, pollId: pollId);
        print("closed");
      }
    }
    print("Created all");
  }
}
