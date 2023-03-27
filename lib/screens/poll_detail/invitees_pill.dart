import 'package:dima_app/screens/profile/profile_pic.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/tables/poll_event_invite_collection.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/pill_box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../widgets/user_list.dart';

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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 100),
      child: SizedBox(
        child: PillBox(
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                ScreenTransition(
                  builder: (context) => Scaffold(
                    appBar: MyAppBar(
                      title: "Partecipants",
                      upRightActions: [MyAppBar.SearchAction(context)],
                    ),
                    body: UserList(
                      users: invites.map((e) => e.inviteeId).toList(),
                    ),
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  SizedBox(
                    height: 80,
                    width: 210,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          child: ProfilePic(
                            userData: Provider.of<FirebaseUser>(context,
                                    listen: false)
                                .userData,
                            loading: false,
                            radius: 40,
                          ),
                        ),
                        Positioned(
                          left: 60,
                          child: ProfilePic(
                            userData: Provider.of<FirebaseUser>(context,
                                    listen: false)
                                .userData,
                            loading: false,
                            radius: 40,
                          ),
                        ),
                        Positioned(
                          left: 120,
                          child: ProfilePic(
                            userData: Provider.of<FirebaseUser>(context,
                                    listen: false)
                                .userData,
                            loading: false,
                            radius: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "${invites.length.toString()} partecipants",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
