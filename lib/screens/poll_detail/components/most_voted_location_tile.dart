import 'package:dima_app/models/location.dart';
import 'package:dima_app/models/location_icons.dart';
import 'package:dima_app/models/poll_event_invite_model.dart';
import 'package:dima_app/models/poll_event_model.dart';
import 'package:dima_app/models/vote_location_model.dart';
import 'package:dima_app/widgets/my_list_tile.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:flutter/material.dart';

import 'location_detail.dart';

class MostVotedLocationTile extends StatelessWidget {
  final PollEventModel pollData;
  final String pollId;
  final List<PollEventInviteModel> invites;
  final List<VoteLocationModel> votesLocations;
  const MostVotedLocationTile({
    super.key,
    required this.votesLocations,
    required this.pollData,
    required this.pollId,
    required this.invites,
  });

  @override
  Widget build(BuildContext context) {
    votesLocations.sort(
        (a, b) => b.getPositiveVotes().length - a.getPositiveVotes().length);
    VoteLocationModel mostVotedLocationVotes = votesLocations.first;
    Location mostVotedLocation = pollData.locations.firstWhere(
      (element) => element.name == mostVotedLocationVotes.locationName,
    );
    return MyListTile(
      horizontalTitleGap: 25,
      leading: SizedBox(
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FittedBox(
              child: Icon(
                LocationIcons.icons[mostVotedLocation.icon],
                size: 35,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text((mostVotedLocationVotes.getPositiveVotes().length)
                    .toString()),
                Container(width: 2),
                const Icon(
                  Icons.check,
                  color: Colors.green,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
      title: mostVotedLocation.name,
      subtitle: mostVotedLocation.site.isEmpty
          ? "No link given"
          : mostVotedLocation.site,
      onTap: () {
        MyModal.show(
          context: context,
          shrinkWrap: false,
          child: LocationDetail(
            isClosed: true,
            pollId: pollId,
            organizerUid: pollData.organizerUid,
            invites: invites,
            location: mostVotedLocation,
            modifyVote: (int value) {},
          ),
          heightFactor: 0.85,
          doneCancelMode: false,
          onDone: () {},
          titleWidget: Container(
            alignment: Alignment.topLeft,
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.headlineMedium,
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: Icon(
                        LocationIcons.icons[mostVotedLocation.icon],
                        size:
                            Theme.of(context).textTheme.headlineLarge!.fontSize,
                        color:
                            Theme.of(context).textTheme.headlineMedium!.color,
                      ),
                    ),
                  ),
                  TextSpan(text: mostVotedLocation.name),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
