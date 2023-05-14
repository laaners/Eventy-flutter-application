import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/models/availability.dart';
import 'package:dima_app/models/location.dart';
import 'package:dima_app/models/location_icons.dart';
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
  const LocationDetail({
    super.key,
    required this.pollId,
    required this.organizerUid,
    required this.invites,
    required this.location,
    required this.modifyVote,
  });

  List<MyPollOption> getOptions(VoteLocationModel? locationModel) {
    return [
      MyPollOption(
        id: Availability.yes,
        title: Row(
          children: [
            Icon(Availability.icons[Availability.yes]),
            const Text(" Present", style: TextStyle(fontSize: 20)),
          ],
        ),
        votes: locationModel != null
            ? 1 +
                (locationModel
                    .getVotesKind(
                      Availability.yes,
                      invites,
                      organizerUid,
                    )
                    .length)
            : 1,
      ),
      MyPollOption(
        id: Availability.iff,
        title: Row(
          children: [
            Icon(Availability.icons[Availability.iff]),
            const Text(" If need be", style: TextStyle(fontSize: 20)),
          ],
        ),
        votes: locationModel != null
            ? locationModel
                .getVotesKind(
                  Availability.iff,
                  invites,
                  organizerUid,
                )
                .length
            : 0,
      ),
      MyPollOption(
        id: Availability.not,
        title: Row(
          children: [
            Icon(Availability.icons[Availability.not]),
            const Text(" Not present", style: TextStyle(fontSize: 20)),
          ],
        ),
        votes: locationModel != null
            ? locationModel
                .getVotesKind(
                  Availability.not,
                  invites,
                  organizerUid,
                )
                .length
            : 0,
      ),
      MyPollOption(
        id: Availability.empty,
        title: Row(
          children: [
            Icon(Availability.icons[Availability.empty]),
            const Text(" Pending", style: TextStyle(fontSize: 20)),
          ],
        ),
        votes: locationModel != null
            ? locationModel
                .getVotesKind(
                  Availability.empty,
                  invites,
                  organizerUid,
                )
                .length
            : invites.length - 1,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8, top: 8, left: 15),
          alignment: Alignment.topLeft,
          child: Text(
            location.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50 + 5),
            ),
            child: IconButton(
              iconSize: 100.0,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {},
              icon: Icon(
                LocationIcons.icons[location.icon],
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 8, top: 8, left: 15),
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
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              child: MyPolls(
                curUid: curUid,
                organizerUid: organizerUid,
                votedAnimationDuration: 0,
                votesText: "",
                hasVoted: true,
                userVotedOptionId: userVotedOptionId,
                heightBetweenTitleAndOptions: 0,
                pollId: '1',
                onVoted: (MyPollOption pollOption, int newTotalVotes) async {
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
                votedCheckmark: const Icon(
                  Icons.check,
                ),
                pollTitle: Container(),
                pollOptions: getOptions(locationModel),
                metaWidget: Row(
                  children: const [
                    Text(
                      '•',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      '2 weeks left',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const Padding(padding: EdgeInsets.only(top: 8)),
        location.name == "Virtual meeting"
            ? ListTile(
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
                  const Padding(padding: EdgeInsets.only(top: 0)),
                  ListTile(
                    title: const Text(
                      "Address",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    horizontalTitleGap: 0,
                    trailing: IconButton(
                      iconSize: 25,
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: location.site),
                        );
                      },
                      icon: const Icon(Icons.copy),
                    ),
                    subtitle: TextFormField(
                      initialValue: location.site,
                      autofocus: false,
                      enabled: false,
                    ),
                  ),
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
