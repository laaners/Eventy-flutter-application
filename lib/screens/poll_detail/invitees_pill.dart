import 'package:dima_app/server/tables/poll_collection.dart';
import 'package:dima_app/server/tables/poll_event_invite_collection.dart';
import 'package:dima_app/server/tables/vote_date_collection.dart';
import 'package:dima_app/server/tables/vote_location_collection.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/pill_box.dart';
import 'package:dima_app/widgets/profile_pics_stack.dart';
import 'package:flutter/material.dart';
import 'invitees_list.dart';

class InviteesPill extends StatelessWidget {
  final PollCollection pollData;
  final String pollEventId;
  final List<PollEventInviteCollection> invites;
  final List<VoteLocationCollection> votesLocations;
  final List<VoteDateCollection> votesDates;

  final VoidCallback refreshPollDetail;
  const InviteesPill({
    super.key,
    required this.pollEventId,
    required this.invites,
    required this.refreshPollDetail,
    required this.pollData,
    required this.votesLocations,
    required this.votesDates,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 70),
      child: SizedBox(
        width: 250,
        child: PillBox(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                if (invites.isNotEmpty)
                  ProfilePicsStack(
                    radius: 40,
                    offset: 30,
                    uids: invites
                        .map((e) => e.inviteeId)
                        .where((e) => e != pollData.organizerUid)
                        .toList()
                        .sublist(
                            0, invites.length < 4 ? invites.length - 1 : 4 - 1),
                  ),
                Container(padding: const EdgeInsets.all(8)),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      ScreenTransition(
                        builder: (context) => InviteesList(
                          pollEventId: pollEventId,
                          pollData: pollData,
                          invites: invites
                              .where(
                                  (e) => e.inviteeId != pollData.organizerUid)
                              .toList(),
                          refreshPollDetail: refreshPollDetail,
                          votesLocations: votesLocations,
                          votesDates: votesDates,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    "${invites.isEmpty ? "0" : (invites.length - 1).toString()} invited",
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
