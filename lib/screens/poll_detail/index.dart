import 'package:dima_app/screens/error.dart';
import 'package:dima_app/screens/poll_detail/dates_list.dart';
import 'package:dima_app/screens/poll_detail/invitees_pill.dart';
import 'package:dima_app/screens/poll_detail/locations_list.dart';
import 'package:dima_app/server/firebase_poll.dart';
import 'package:dima_app/server/firebase_poll_event_invite.dart';
import 'package:dima_app/server/tables/poll_collection.dart';
import 'package:dima_app/server/tables/poll_event_invite_collection.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/loading_spinner.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/user_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PollDetailScreen extends StatelessWidget {
  final String pollId;

  const PollDetailScreen({
    super.key,
    required this.pollId,
  });

  Future<Map<String, dynamic>?> getPollDataAndInvites(
      BuildContext context) async {
    PollCollection? pollData =
        await Provider.of<FirebasePoll>(context, listen: false)
            .getPollData(context, pollId);
    if (pollData == null) return null;
    List<PollEventInviteCollection> pollInvites =
        // ignore: use_build_context_synchronously
        await Provider.of<FirebasePollEventInvite>(context, listen: false)
            .getInvitesFromPollEventId(context, pollId);
    if (pollInvites.isEmpty) return null;
    return {"data": pollData, "invites": pollInvites};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar("Poll Detail"),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: getPollDataAndInvites(context),
        builder: (
          BuildContext context,
          AsyncSnapshot<Map<String, dynamic>?> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingSpinner();
          }
          if (snapshot.hasError || !snapshot.hasData) {
            Future.microtask(() {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                ScreenTransition(
                  builder: (context) => ErrorScreen(
                    errorMsg: snapshot.error.toString(),
                  ),
                ),
              );
            });
            return Container();
          }
          PollCollection pollData = snapshot.data!["data"];
          List<PollEventInviteCollection> pollInvites =
              snapshot.data!["invites"];
          return Container(
            margin: const EdgeInsets.all(10),
            child: ListView(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  child: Center(
                    child: Text(
                      pollData.pollName,
                      style: const TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.normal,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                ),
                const Text(
                  "Organized by",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                UserTile(userUid: pollData.organizerUid),
                const Text(
                  "About this event",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Container(padding: const EdgeInsets.symmetric(vertical: 5)),
                Text(pollData.pollDesc.isEmpty
                    ? "The organized did not provide any description"
                    : pollData.pollDesc),
                Container(padding: const EdgeInsets.symmetric(vertical: 5)),
                InviteesPill(
                  pollEventId: pollId,
                  invites: pollInvites,
                ),
                Container(padding: const EdgeInsets.symmetric(vertical: 5)),
                const Text(
                  "Where this event could be held",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Container(padding: const EdgeInsets.symmetric(vertical: 5)),
                LocationsList(
                  organizerUid: pollData.organizerUid,
                  pollId: pollId,
                  locations: pollData.locations,
                  invites: pollInvites,
                ),
                Container(padding: const EdgeInsets.symmetric(vertical: 5)),
                const Text(
                  "When this event could be held",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Container(padding: const EdgeInsets.symmetric(vertical: 5)),
                DatesList(
                  organizerUid: pollData.organizerUid,
                  pollId: pollId,
                  dates: pollData.dates,
                  invites: pollInvites,
                ),
                Text(pollData.deadline),
                Text(pollData.public.toString()),
              ],
            ),
          );
        },
      ),
    );
  }
}
