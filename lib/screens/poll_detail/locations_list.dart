import 'package:dima_app/screens/poll_detail/location_detail.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/tables/location.dart';
import 'package:dima_app/server/tables/location_icons.dart';
import 'package:dima_app/server/tables/poll_event_invite_collection.dart';
import 'package:dima_app/server/tables/vote_location_collection.dart';
import 'package:dima_app/widgets/my_button.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LocationsList extends StatefulWidget {
  final String organizerUid;
  final String pollId;
  final List<Map<String, dynamic>> locations;
  final List<PollEventInviteCollection> invites;
  final List<VoteLocationCollection> votesLocations;
  const LocationsList({
    super.key,
    required this.locations,
    required this.pollId,
    required this.organizerUid,
    required this.invites,
    required this.votesLocations,
  });

  @override
  State<LocationsList> createState() => _LocationsListState();
}

class _LocationsListState extends State<LocationsList> {
  bool sortedByVotes = true;
  late List<VoteLocationCollection> votesLocations;

  @override
  void initState() {
    super.initState();
    votesLocations = widget.votesLocations;
  }

  @override
  Widget build(BuildContext context) {
    var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    return Column(
      children: [
        Container(
          alignment: Alignment.topRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    votesLocations.sort(
                        (a, b) => a.locationName.compareTo(b.locationName));
                  });
                },
                icon: Icon(
                  Icons.sort_by_alpha,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    votesLocations.sort((a, b) =>
                        b.getPositiveVotes().length -
                        a.getPositiveVotes().length);
                  });
                },
                icon: Icon(
                  Icons.sort,
                ),
              ),
            ],
          ),
        ),
        Column(
          children: votesLocations.map((voteLocation) {
            var location = widget.locations.firstWhere(
              (element) => element["name"] == voteLocation.locationName,
            );
            return LocationTile(
              pollId: widget.pollId,
              organizerUid: widget.organizerUid,
              invites: widget.invites,
              location: Location(
                location["name"],
                location["site"],
                location["lat"],
                location["lon"],
                location["icon"],
              ),
              voteLocation: voteLocation,
              modifyVote: (int newAvailability) {
                setState(() {
                  votesLocations[votesLocations.indexWhere(
                          (e) => e.locationName == location["name"])]
                      .votes[curUid] = newAvailability;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class LocationTile extends StatelessWidget {
  final String pollId;
  final String organizerUid;
  final List<PollEventInviteCollection> invites;
  final Location location;
  final VoteLocationCollection voteLocation;
  final ValueChanged<int> modifyVote;
  const LocationTile({
    super.key,
    required this.pollId,
    required this.organizerUid,
    required this.invites,
    required this.location,
    required this.voteLocation,
    required this.modifyVote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        title: Text(
          location.name,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          location.site,
          overflow: TextOverflow.ellipsis,
        ),
        leading: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(
            LocationIcons.icons[location.icon],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text((voteLocation.getPositiveVotes().length).toString()),
            IconButton(
              icon: const Icon(
                Icons.check,
                color: Colors.green,
              ),
              onPressed: () {},
            ),
          ],
        ),
        onTap: () async {
          /*
          await showModalBottomSheet(
            useRootNavigator: true,
            isScrollControlled: true,
            context: context,
            builder: (context) => FractionallySizedBox(
              heightFactor: 0.85,
              child: LocationDetail(
                pollId: pollId,
                organizerUid: organizerUid,
                invites: invites,
                location: location,
                modifyVote: modifyVote,
              ),
            ),
          );
          */
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
          Navigator.push(
            context,
            ScreenTransition(
              builder: (context) => Scaffold(
                appBar: MyAppBar(location.name),
                body: Container(
                  // margin: const EdgeInsets.only(top: 15, bottom: 15),
                  child: LocationDetail(
                    pollId: pollId,
                    organizerUid: organizerUid,
                    invites: invites,
                    location: location,
                    modifyVote: modifyVote,
                  ),
                ),
              ),
            ),
          );
          */
          // modifyVote(Availability.not);
        },
      ),
    );
  }
}
