import 'package:dima_app/models/availability.dart';
import 'package:dima_app/models/location.dart';
import 'package:dima_app/models/location_icons.dart';
import 'package:dima_app/models/poll_event_invite_model.dart';
import 'package:dima_app/models/vote_location_model.dart';
import 'package:dima_app/screens/poll_detail/components/location_detail.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/services/firebase_vote.dart';
import 'package:dima_app/widgets/my_alert_dialog.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class LocationsList extends StatefulWidget {
  final String organizerUid;
  final String votingUid;
  final String pollId;
  final List<Location> locations;
  final List<PollEventInviteModel> invites;
  final List<VoteLocationModel> votesLocations;
  const LocationsList({
    super.key,
    required this.locations,
    required this.pollId,
    required this.organizerUid,
    required this.invites,
    required this.votesLocations,
    required this.votingUid,
  });

  @override
  State<LocationsList> createState() => _LocationsListState();
}

class _LocationsListState extends State<LocationsList>
    with AutomaticKeepAliveClientMixin {
  bool votesDesc = true;
  bool alphabeticAsc = true;
  late List<VoteLocationModel> votesLocations;

  @override
  void initState() {
    super.initState();
    votesLocations = widget.votesLocations;
    votesLocations.sort((a, b) =>
        a.locationName.toLowerCase().compareTo(b.locationName.toLowerCase()));
    votesLocations.sort(
        (a, b) => b.getPositiveVotes().length - a.getPositiveVotes().length);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    return Stack(
      children: [
        Container(
          alignment: Alignment.topRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    alphabeticAsc = !alphabeticAsc;
                    alphabeticAsc
                        ? votesLocations.sort((a, b) => a.locationName
                            .toLowerCase()
                            .compareTo(b.locationName.toLowerCase()))
                        : votesLocations.sort((a, b) => b.locationName
                            .toLowerCase()
                            .compareTo(a.locationName.toLowerCase()));
                  });
                },
                icon: const Icon(
                  Icons.sort_by_alpha,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    votesDesc = !votesDesc;
                    votesDesc
                        ? votesLocations.sort((a, b) =>
                            b.getPositiveVotes().length -
                            a.getPositiveVotes().length)
                        : votesLocations.sort((a, b) =>
                            a.getPositiveVotes().length -
                            b.getPositiveVotes().length);
                  });
                },
                icon: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationX(votesDesc ? 0 : math.pi),
                  child: const Icon(
                    Icons.sort,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 50),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: votesLocations.map((voteLocation) {
                    var location = widget.locations.firstWhere(
                      (element) => element.name == voteLocation.locationName,
                    );
                    return LocationTile(
                      votingUid: widget.votingUid,
                      pollId: widget.pollId,
                      organizerUid: widget.organizerUid,
                      invites: widget.invites,
                      location: Location(
                        location.name,
                        location.site,
                        location.lat,
                        location.lon,
                        location.icon,
                      ),
                      voteLocation: voteLocation,
                      modifyVote: (int newAvailability) {
                        if (widget.votingUid == curUid) {
                          setState(() {
                            votesLocations[votesLocations.indexWhere(
                                    (e) => e.locationName == location.name)]
                                .votes[curUid] = newAvailability;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LocationTile extends StatelessWidget {
  final String votingUid;
  final String pollId;
  final String organizerUid;
  final List<PollEventInviteModel> invites;
  final Location location;
  final VoteLocationModel voteLocation;
  final ValueChanged<int> modifyVote;
  const LocationTile({
    super.key,
    required this.pollId,
    required this.organizerUid,
    required this.invites,
    required this.location,
    required this.voteLocation,
    required this.modifyVote,
    required this.votingUid,
  });

  @override
  Widget build(BuildContext context) {
    var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    int curVote = voteLocation.votes[votingUid] ?? Availability.empty;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        minLeadingWidth: 0,
        minVerticalPadding: 0,
        title: Text(
          location.name,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          location.site,
          overflow: TextOverflow.ellipsis,
        ),
        leading: SizedBox(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(LocationIcons.icons[location.icon]),
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
        trailing: SizedBox(
          height: double.infinity,
          child: InkWell(
            customBorder: const CircleBorder(),
            child: Ink(
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: Icon(Availability.icons[curVote]),
            ),
            onTap: () async {
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
        ),
        onTap: () async {
          MyModal.show(
            context: context,
            child: LocationDetail(
              pollId: pollId,
              organizerUid: organizerUid,
              invites: invites,
              location: location,
              modifyVote: modifyVote,
            ),
            heightFactor: 0.85,
            doneCancelMode: false,
            onDone: () {},
            title: "",
          );
          /*
          */
          return;
          // modifyVote(Availability.not);
        },
      ),
    );
  }
}
