import 'dart:math';

import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/firebase_vote.dart';
import 'package:dima_app/server/tables/poll_event_invite_collection.dart';
import 'package:dima_app/themes/palette.dart';
import 'package:dima_app/widgets/pill_box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InviteesPill extends StatelessWidget {
  final String pollEventId;
  final List<PollEventInviteCollection> invites;
  const InviteesPill({
    super.key,
    required this.pollEventId,
    required this.invites,
  });

  @override
  Widget build(BuildContext context) {
    void insert() async {
      var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
      for (var e in invites) {
        var uid = e.inviteeId;
        if (uid == curUid) continue;
        final random = Random();
        int next(int min, int max) => min + random.nextInt(max - min);
        /*
        await Provider.of<FirebaseVote>(context, listen: false)
            .userVoteLocation(
          context,
          pollEventId,
          "Virtual meeting",
          uid,
          next(-1, 3),
        );
        print("added");
        */

        await Provider.of<FirebaseVote>(context, listen: false).userVoteDate(
          context,
          pollEventId,
          "2023-03-25",
          "20:10",
          "18:10",
          uid,
          next(-1, 3),
        );
        print("added");
        /*
        */
      }
    }

    return Container(
      width: 40,
      margin: const EdgeInsets.symmetric(horizontal: 50),
      child: SizedBox(
        child: PillBox(
          child: InkWell(
            onTap: () {
              /*
              Navigator.push(
                context,
                ScreenTransition(
                  builder: (context) => Scaffold(
                    appBar: const MyAppBar("Poll Partecipants"),
                    body: UserList(
                      users: invites.map((e) {
                        return e.inviteeId;
                      }).toList(),
                    ),
                  ),
                ),
              );
              */
              insert();
            },
            child: Row(
              children: [
                Text(
                  "${invites.length.toString()} partecipants",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_sharp,
                  color: Palette.greyColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
