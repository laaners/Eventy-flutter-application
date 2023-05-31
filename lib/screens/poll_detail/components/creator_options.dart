// ignore_for_file: use_build_context_synchronously

import 'package:dima_app/models/poll_event_invite_model.dart';
import 'package:dima_app/models/poll_event_model.dart';
import 'package:dima_app/models/vote_date_model.dart';
import 'package:dima_app/models/vote_location_model.dart';
import 'package:dima_app/screens/poll_detail/components/invitees_list.dart';
import 'package:dima_app/services/dynamic_links_handler.dart';
import 'package:dima_app/widgets/loading_overlay.dart';
import 'package:dima_app/widgets/my_alert_dialog.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class CreatorOptions extends StatelessWidget {
  final PollEventModel pollData;
  final String pollEventId;
  final List<PollEventInviteModel> invites;
  final VoidCallback refreshPollDetail;
  final List<VoteLocationModel> votesLocations;
  final List<VoteDateModel> votesDates;
  const CreatorOptions({
    super.key,
    required this.pollData,
    required this.pollEventId,
    required this.invites,
    required this.refreshPollDetail,
    required this.votesLocations,
    required this.votesDates,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.all(0),
          title: Text(
            "Share the poll",
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          leading: Container(
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.share_outlined,
            ),
          ),
          onTap: () async {
            await DynamicLinksHandler.pollEventLinkSharing(
              context: context,
              pollData: pollData,
            );
          },
        ),
        ListTile(
          contentPadding: const EdgeInsets.all(0),
          title: Text(
            "Manage invited users",
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          leading: Container(
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.person_add,
            ),
          ),
          onTap: () {
            Navigator.pushReplacement(
              context,
              ScreenTransition(
                builder: (context) => InviteesList(
                  pollEventId: pollEventId,
                  pollData: pollData,
                  invites: invites
                      .where((e) => e.inviteeId != pollData.organizerUid)
                      .toList(),
                  refreshPollDetail: refreshPollDetail,
                  votesDates: votesDates,
                  votesLocations: votesLocations,
                ),
              ),
            );
          },
        ),
        ListTile(
          contentPadding: const EdgeInsets.all(0),
          title: Text(
            "Close the poll",
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          leading: Container(
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.event_available,
            ),
          ),
          onTap: () async {
            bool ris = await MyAlertDialog.showAlertConfirmCancel(
              context: context,
              title: "Closing the poll",
              content:
                  "Do you want to close the poll early and create the event?",
              trueButtonText: "Confirm",
            );
            if (ris) {
              // ignore: use_build_context_synchronously
              Navigator.pop(context, "create_event_${pollData.organizerUid}");
            }
          },
        ),
        ListTile(
          contentPadding: const EdgeInsets.all(0),
          title: Text(
            "Delete the poll",
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          leading: Container(
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.delete,
            ),
          ),
          onTap: () async {
            bool ris = await MyAlertDialog.showAlertConfirmCancel(
              context: context,
              title: "Deleting the poll",
              content:
                  "This action will delete the poll without creating the event, continue?",
              trueButtonText: "Confirm",
            );
            if (ris) {
              Navigator.pop(context, "delete_poll_${pollData.organizerUid}");
            }
          },
        ),
      ],
    );
  }
}
