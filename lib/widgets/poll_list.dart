import 'package:dima_app/screens/error.dart';
import 'package:dima_app/screens/home.dart';
import 'package:dima_app/screens/poll_detail/index.dart';
import 'package:dima_app/screens/poll_event.dart';
import 'package:dima_app/server/firebase_poll.dart';
import 'package:dima_app/server/firebase_poll_event_invite.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/tables/poll_event_collection.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/loading_spinner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PollList extends StatefulWidget {
  final String userUid;

  const PollList({
    super.key,
    required this.userUid,
  });

  @override
  State<PollList> createState() => _PollListState();
}

class _PollListState extends State<PollList> {
  int _refresh = 1;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<FirebasePoll>(context, listen: false)
          .getOtherUserPublicOrInvitedPolls(context, widget.userUid),
      builder: (
        context,
        snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingSpinner();
        }
        if (snapshot.hasError) {
          Future.microtask(() {
            Navigator.of(context).pushReplacement(
              ScreenTransition(
                builder: (context) => ErrorScreen(
                  errorMsg: snapshot.error.toString(),
                ),
              ),
            );
          });
          return Container();
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            child: const Text("empty"),
          );
        }
        var pollsData = snapshot.data!;
        return ListView(
          children: pollsData
              .map(
                (e) => PollTile(
                  pollData: e["pollDetails"] as PollEventCollection,
                  invited: e["invited"] as bool,
                  refreshParent: () {
                    setState(() {
                      _refresh += 1;
                    });
                  },
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class PollTile extends StatelessWidget {
  final PollEventCollection pollData;
  final bool invited;
  final VoidCallback refreshParent;
  const PollTile({
    super.key,
    required this.pollData,
    required this.invited,
    required this.refreshParent,
  });

  @override
  Widget build(BuildContext context) {
    String pollId = "${pollData.pollEventName}_${pollData.organizerUid}";
    return SizedBox(
      height: 80,
      child: ListTile(
        /*
        trailing: Text(
            "public: ${pollData.public.toString()}, canInvite: ${pollData.canInvite.toString()}, invited: ${invited.toString()}"),
        */
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.place),
        ),
        title: Text(pollData.pollEventName),
        subtitle: Text(pollData.organizerUid),
        onTap: () async {
          var curUid =
              Provider.of<FirebaseUser>(context, listen: false).user!.uid;
          // if not invited and is a public event, add invite
          if (!invited && pollData.public) {
            await Provider.of<FirebasePollEventInvite>(context, listen: false)
                .createPollEventInvite(
              context: context,
              pollEventId: pollId,
              inviteeId: curUid,
            );
            refreshParent();
          }

          Widget newScreen = PollEventScreen(pollEventId: pollId);
          // ignore: use_build_context_synchronously
          var ris = await Navigator.of(context, rootNavigator: false).push(
            ScreenTransition(
              builder: (context) => newScreen,
            ),
          );
          if (ris == "delete_poll_$curUid") {
            // ignore: use_build_context_synchronously
            await Provider.of<FirebasePoll>(context, listen: false).closePoll(
              context: context,
              pollId: pollId,
            );
          }
        },
      ),
    );
  }
}
