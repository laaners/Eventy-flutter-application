import 'package:flutter/material.dart';
import 'package:dima_app/models/availability.dart';
import 'package:dima_app/models/location.dart';
import 'package:dima_app/models/location_icons.dart';
import 'package:dima_app/models/poll_event_invite_model.dart';
import 'package:dima_app/models/vote_location_model.dart';
import 'package:dima_app/screens/poll_detail/components/location_detail.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/services/firebase_vote.dart';
import 'package:dima_app/widgets/my_alert_dialog.dart';
import 'package:dima_app/widgets/my_icon_button.dart';
import 'package:dima_app/widgets/my_list_tile.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:provider/provider.dart';

class LocationTile extends StatelessWidget {
  final Location location;
  final VoteLocationModel voteLocation;
  final bool isClosed;
  final String organizerUid;
  final String votingUid;
  final String pollId;
  final List<PollEventInviteModel> invites;
  final ValueChanged<int> modifyVote;
  const LocationTile({
    super.key,
    required this.location,
    required this.voteLocation,
    required this.isClosed,
    required this.organizerUid,
    required this.votingUid,
    required this.pollId,
    required this.invites,
    required this.modifyVote,
  });

  @override
  Widget build(BuildContext context) {
    var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    int curVote = voteLocation.votes[votingUid] ?? Availability.empty;
    return MyListTile(
      horizontalTitleGap: 25,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
      title: location.name,
      subtitle: location.site,
      leading: SizedBox(
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FittedBox(
                child: Icon(
              LocationIcons.icons[location.icon],
              size: 35,
            )),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text((voteLocation.getPositiveVotes().length).toString()),
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
      trailing: MyIconButton(
        icon: Icon(Availability.icons[curVote]),
        onTap: () async {
          if (isClosed) return;
          if (votingUid == curUid) {
            if (MyAlertDialog.showAlertIfCondition(
              context: context,
              condition: votingUid == organizerUid,
              title: "You cannot vote",
              content:
                  "You are the organizer, you must be present at the event!",
            )) {
              return;
            }
            int newAvailability =
                curVote + 1 > 2 ? Availability.empty : curVote + 1;
            await Provider.of<FirebaseVote>(context, listen: false)
                .userVoteLocation(
              pollId: pollId,
              locationName: location.name,
              uid: votingUid,
              availability: newAvailability,
            );
            modifyVote(newAvailability);
          }
        },
      ),
      onTap: () async {
        await MyModal.show(
          context: context,
          child: LocationDetail(
            isClosed: isClosed,
            pollId: pollId,
            organizerUid: organizerUid,
            invites: invites,
            location: location,
            modifyVote: modifyVote,
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
                        LocationIcons.icons[location.icon],
                        size:
                            Theme.of(context).textTheme.headlineLarge!.fontSize,
                        color:
                            Theme.of(context).textTheme.headlineMedium!.color,
                      ),
                    ),
                  ),
                  TextSpan(text: location.name),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
