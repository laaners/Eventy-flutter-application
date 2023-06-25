import 'package:dima_app/constants/layout_constants.dart';
import 'package:dima_app/models/availability.dart';
import 'package:dima_app/models/location.dart';
import 'package:dima_app/models/poll_event_invite_model.dart';
import 'package:dima_app/models/vote_location_model.dart';
import 'package:dima_app/screens/poll_detail/components/availability_legend.dart';
import 'package:dima_app/screens/poll_detail/components/location_tile.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/empty_list.dart';
import 'package:dima_app/widgets/my_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class LocationsList extends StatefulWidget {
  final bool isClosed;
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
    required this.isClosed,
  });

  @override
  State<LocationsList> createState() => _LocationsListState();
}

class _LocationsListState extends State<LocationsList>
    with AutomaticKeepAliveClientMixin {
  bool votesDesc = true;
  bool alphabeticAsc = true;
  int filterAvailability = -2;
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

  updateFilterAfterVote() {
    if (filterAvailability == -2) return;
    setState(() {
      filterAvailability = -2;
      votesLocations = widget.votesLocations;
      alphabeticAsc
          ? votesLocations.sort((a, b) => a.locationName
              .toLowerCase()
              .compareTo(b.locationName.toLowerCase()))
          : votesLocations.sort((a, b) => b.locationName
              .toLowerCase()
              .compareTo(a.locationName.toLowerCase()));
      votesDesc
          ? votesLocations.sort((a, b) =>
              b.getPositiveVotes().length - a.getPositiveVotes().length)
          : votesLocations.sort((a, b) =>
              a.getPositiveVotes().length - b.getPositiveVotes().length);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    return Stack(
      children: [
        Container(
          alignment: Alignment.topRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AvailabilityLegend(
                filterAvailability: filterAvailability,
                changeFilterAvailability: (int value) {
                  setState(() {
                    filterAvailability = value;
                    if (value == -2) {
                      votesLocations = widget.votesLocations;
                    } else if (value == Availability.empty) {
                      votesLocations = widget.votesLocations
                          .where((voteLocation) =>
                              voteLocation.votes[widget.votingUid] == null ||
                              voteLocation.votes[widget.votingUid] == value)
                          .toList();
                    } else {
                      votesLocations = widget.votesLocations
                          .where((voteLocation) =>
                              voteLocation.votes[widget.votingUid] == value)
                          .toList();
                    }
                    alphabeticAsc
                        ? votesLocations.sort((a, b) => a.locationName
                            .toLowerCase()
                            .compareTo(b.locationName.toLowerCase()))
                        : votesLocations.sort((a, b) => b.locationName
                            .toLowerCase()
                            .compareTo(a.locationName.toLowerCase()));
                    votesDesc
                        ? votesLocations.sort((a, b) =>
                            b.getPositiveVotes().length -
                            a.getPositiveVotes().length)
                        : votesLocations.sort((a, b) =>
                            a.getPositiveVotes().length -
                            b.getPositiveVotes().length);
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyIconButton(
                    onTap: () {
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
                    icon: const Icon(Icons.sort_by_alpha),
                  ),
                  MyIconButton(
                    margin: const EdgeInsets.only(
                        right: LayoutConstants.kHorizontalPadding),
                    onTap: () {
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
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 50),
          child: votesLocations.isEmpty
              ? ListView(
                  shrinkWrap: true,
                  controller: ScrollController(),
                  children: const [
                    EmptyList(emptyMsg: "Nothing here"),
                  ],
                )
              : ListView.builder(
                  itemCount: votesLocations.length,
                  physics: const ClampingScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    VoteLocationModel voteLocation = votesLocations[index];
                    Location location = widget.locations.firstWhere(
                      (element) => element.name == voteLocation.locationName,
                    );
                    return LocationTile(
                      location: location,
                      voteLocation: voteLocation,
                      isClosed: widget.isClosed,
                      organizerUid: widget.organizerUid,
                      votingUid: widget.votingUid,
                      pollId: widget.pollId,
                      invites: widget.invites,
                      modifyVote: (int newAvailability) {
                        if (widget.isClosed) return;
                        if (widget.votingUid == curUid) {
                          setState(() {
                            votesLocations[votesLocations.indexWhere(
                                    (e) => e.locationName == location.name)]
                                .votes[curUid] = newAvailability;
                          });
                          updateFilterAfterVote();
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
