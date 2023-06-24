import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/models/availability.dart';
import 'package:dima_app/models/location.dart';
import 'package:dima_app/models/poll_event_invite_model.dart';
import 'package:dima_app/models/vote_location_model.dart';
import 'package:dima_app/screens/error/error.dart';
import 'package:dima_app/screens/poll_detail/components/availability_legend.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/services/firebase_vote.dart';
import 'package:dima_app/widgets/empty_list.dart';
import 'package:dima_app/widgets/horizontal_scroller.dart';
import 'package:dima_app/widgets/loading_logo.dart';
import 'package:dima_app/widgets/map_widget.dart';
import 'package:dima_app/widgets/profile_pic.dart';
import 'package:dima_app/widgets/profile_pics_stack.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'my_poll.dart';

class LocationDetail extends StatefulWidget {
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

  @override
  State<LocationDetail> createState() => _LocationDetailState();
}

class _LocationDetailState extends State<LocationDetail> {
  int filterAvailability = -2;

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
        invites: widget.invites,
        organizerUid: widget.organizerUid,
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
          alignment: Alignment.topLeft,
          child: Text(
            "Votes",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Row(
          children: [
            AvailabilityLegend(
              filterAvailability: filterAvailability,
              changeFilterAvailability: (int value) {
                setState(() {
                  filterAvailability = value;
                });
              },
            ),
          ],
        ),
        StreamBuilder(
          stream: Provider.of<FirebaseVote>(context, listen: false)
              .getVoteLocationSnapshot(
                  pollId: widget.pollId, locationName: widget.location.name),
          builder: (
            BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Object?>> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 104);
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
            VoteLocationModel? voteLocation;
            var curUid =
                Provider.of<FirebaseUser>(context, listen: false).user!.uid;
            int userVotedOptionId = Availability.empty;
            if (snapshot.data!.exists) {
              voteLocation = VoteLocationModel.fromMap(
                (snapshot.data!.data()) as Map<String, dynamic>,
              );
              userVotedOptionId =
                  voteLocation.votes[curUid] ?? Availability.empty;
            }
            userVotedOptionId = widget.organizerUid == curUid
                ? Availability.yes
                : userVotedOptionId;
            if (filterAvailability != -2) {
              List<String> votesKindUids = VoteLocationModel.getVotesKind(
                voteLocation: voteLocation,
                kind: filterAvailability,
                invites: widget.invites,
                organizerUid: widget.organizerUid,
              ).keys.toList();
              if (votesKindUids.contains(curUid)) {
                votesKindUids.remove(curUid);
                votesKindUids.insert(0, curUid);
              }
              return votesKindUids.isEmpty
                  ? const EmptyList(emptyMsg: "Nothing here")
                  : HorizontalScroller(
                      children: votesKindUids
                          .map((uid) => ProfilePicFromUid(
                                userUid: uid,
                                showUserName: true,
                                radius: 35,
                              ))
                          .toList());
            }
            return MyPolls(
              isClosed: widget.isClosed,
              curUid: curUid,
              organizerUid: widget.organizerUid,
              votedAnimationDuration: 0,
              votesText: "",
              hasVoted: true,
              userVotedOptionId: userVotedOptionId,
              heightBetweenTitleAndOptions: 0,
              pollId: '1',
              onVoted: (MyPollOption pollOption, int newTotalVotes) async {
                if (widget.isClosed) return true;
                int newAvailability = pollOption.id!;
                await Provider.of<FirebaseVote>(context, listen: false)
                    .userVoteLocation(
                  pollId: widget.pollId,
                  locationName: widget.location.name,
                  uid: curUid,
                  availability: newAvailability,
                );
                widget.modifyVote(newAvailability);
                return true;
              },
              pollOptionsSplashColor: Colors.white,
              votedProgressColor: Colors.grey.withOpacity(0.3),
              votedBackgroundColor: Colors.grey.withOpacity(0.2),
              votedCheckmark: const Icon(Icons.check),
              pollTitle: Container(),
              pollOptions: getOptions(voteLocation),
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
        widget.location.name == "Virtual meeting"
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
                  initialValue: widget.location.site.isEmpty
                      ? "The organizer did not provide any link"
                      : widget.location.site,
                  autofocus: false,
                  decoration: InputDecoration(
                    isDense: true,
                    suffixIcon: IconButton(
                      iconSize: 25,
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: widget.location.site),
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
                      initialValue: widget.location.site,
                      // enabled: false,
                      decoration: InputDecoration(
                        isDense: true,
                        suffixIcon: IconButton(
                          iconSize: 25,
                          onPressed: () async {
                            await Clipboard.setData(
                                ClipboardData(text: widget.location.site));
                          },
                          icon: const Icon(Icons.copy),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 15)),
                  MapFromCoor(
                    lat: widget.location.lat,
                    lon: widget.location.lon,
                    address: widget.location.site,
                  ),
                ],
              ),
      ],
    );
  }
}
