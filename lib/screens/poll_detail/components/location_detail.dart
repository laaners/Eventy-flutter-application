import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/models/availability.dart';
import 'package:dima_app/models/location.dart';
import 'package:dima_app/models/poll_event_invite_model.dart';
import 'package:dima_app/models/vote_location_model.dart';
import 'package:dima_app/screens/error/error.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/services/firebase_vote.dart';
import 'package:dima_app/widgets/loading_logo.dart';
import 'package:dima_app/widgets/map_widget.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'my_poll.dart';

class LocationDetail extends StatelessWidget {
  final String pollId;
  final String organizerUid;
  final List<PollEventInviteModel> invites;
  final Location location;
  final ValueChanged<int> modifyVote;
  final bool isClosed;
  const LocationDetail({
    super.key,
    required this.pollId,
    required this.organizerUid,
    required this.invites,
    required this.location,
    required this.modifyVote,
    required this.isClosed,
  });

  List<MyPollOption> getOptions(VoteLocationModel? voteLocation) {
    return [
      Availability.yes,
      Availability.iff,
      Availability.not,
      Availability.empty
    ].map((availability) {
      Map<String, dynamic> votesKind = VoteLocationModel.getVotesKind(
        voteLocation: voteLocation,
        kind: availability,
        invites: invites,
        organizerUid: organizerUid,
      );
      return MyPollOption(
        id: availability,
        title: Row(
          children: [
            Icon(Availability.icons[availability]),
            Text(
              " ${votesKind.length} ${Availability.description(availability)}",
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
        votes: votesKind.length,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          alignment: Alignment.topLeft,
          child: Text(
            "Votes",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const Padding(padding: EdgeInsets.only(top: 8)),
        StreamBuilder(
          stream: Provider.of<FirebaseVote>(context, listen: false)
              .getVoteLocationSnapshot(
                  pollId: pollId, locationName: location.name),
          builder: (
            BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Object?>> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingLogo();
            }
            if (snapshot.hasError) {
              Future.microtask(() {
                Navigator.pushReplacement(
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
            VoteLocationModel? locationModel;
            var curUid =
                Provider.of<FirebaseUser>(context, listen: false).user!.uid;
            int userVotedOptionId = Availability.empty;
            if (snapshot.data!.exists) {
              locationModel = VoteLocationModel.fromMap(
                (snapshot.data!.data()) as Map<String, dynamic>,
              );
              userVotedOptionId =
                  locationModel.votes[curUid] ?? Availability.empty;
            }
            userVotedOptionId =
                organizerUid == curUid ? Availability.yes : userVotedOptionId;
            return MyPolls(
              isClosed: isClosed,
              curUid: curUid,
              organizerUid: organizerUid,
              votedAnimationDuration: 0,
              votesText: "",
              hasVoted: true,
              userVotedOptionId: userVotedOptionId,
              heightBetweenTitleAndOptions: 0,
              pollId: '1',
              onVoted: (MyPollOption pollOption, int newTotalVotes) async {
                if (isClosed) return true;
                int newAvailability = pollOption.id!;
                await Provider.of<FirebaseVote>(context, listen: false)
                    .userVoteLocation(
                  pollId: pollId,
                  locationName: location.name,
                  uid: curUid,
                  availability: newAvailability,
                );
                modifyVote(newAvailability);
                return true;
              },
              pollOptionsSplashColor: Colors.white,
              votedProgressColor: Colors.grey.withOpacity(0.3),
              votedBackgroundColor: Colors.grey.withOpacity(0.2),
              votedCheckmark: const Icon(Icons.check),
              pollTitle: Container(),
              pollOptions: getOptions(locationModel),
              metaWidget: Row(
                children: [
                  Flexible(
                    child: Text(
                      'Your vote: ${Availability.description(userVotedOptionId).toLowerCase()} ',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  Icon(Availability.icons[userVotedOptionId])
                ],
              ),
            );
          },
        ),
        location.name == "Virtual meeting"
            ? ListTile(
                contentPadding: const EdgeInsets.all(0),
                minLeadingWidth: 0,
                horizontalTitleGap: 0,
                title: Container(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Text(
                    "Virtual room link",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                subtitle: TextFormField(
                  initialValue: location.site.isEmpty
                      ? "The organizer did not provide any link"
                      : location.site,
                  autofocus: false,
                  decoration: InputDecoration(
                    isDense: true,
                    suffixIcon: IconButton(
                      iconSize: 25,
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: location.site),
                        );
                      },
                      icon: const Icon(Icons.copy),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              )
            : Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.all(0),
                    minLeadingWidth: 0,
                    horizontalTitleGap: 0,
                    title: Container(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                        "Address",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    subtitle: TextFormField(
                      autofocus: false,
                      initialValue: location.site,
                      // enabled: false,
                      decoration: InputDecoration(
                        isDense: true,
                        suffixIcon: IconButton(
                          iconSize: 25,
                          onPressed: () async {
                            await Clipboard.setData(
                                ClipboardData(text: location.site));
                          },
                          icon: const Icon(Icons.copy),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 15)),
                  MapFromCoor(
                    lat: location.lat,
                    lon: location.lon,
                    address: location.site,
                  ),
                ],
              ),
      ],
    );
  }
}
