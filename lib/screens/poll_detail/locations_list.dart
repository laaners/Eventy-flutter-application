import 'package:dima_app/screens/poll_detail/location_detail.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/tables/location.dart';
import 'package:dima_app/server/tables/poll_event_invite_collection.dart';
import 'package:dima_app/server/tables/vote_location_collection.dart';
import 'package:dima_app/themes/palette.dart';
import 'package:dima_app/widgets/my_button.dart';
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
        MyButton(
          text: "sort test",
          onPressed: () {
            setState(() {
              sortedByVotes = !sortedByVotes;
              if (sortedByVotes) {
                votesLocations.sort((a, b) =>
                    b.getPositiveVotes().length - a.getPositiveVotes().length);
              } else {
                votesLocations.sort((a, b) => a.votes.length - b.votes.length);
              }
            });
          },
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
                location["desc"],
                location["site"],
                location["lat"],
                location["lon"],
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
            color: Palette.greyColor,
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
            color: Palette.lightBGColor,
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            Icons.location_on_outlined,
            color: Palette.greyColor,
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
/*
class LocationsList2 extends StatefulWidget {
  final String organizerUid;
  final String pollId;
  final List<Map<String, dynamic>> locations;
  final List<PollEventInviteCollection> invites;
  const LocationsList2({
    super.key,
    required this.locations,
    required this.pollId,
    required this.organizerUid,
    required this.invites,
  });

  @override
  State<LocationsList2> createState() => _LocationsList2State();
}

class _LocationsList2State extends State<LocationsList2> {
  bool sortedByVotes = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MyButton(
          text: "sort test",
          onPressed: () {
            setState(() {
              sortedByVotes = !sortedByVotes;
            });
          },
        ),
        StreamBuilder(
          stream: Provider.of<FirebaseVote>(context, listen: false)
              .getVotesLocationsSnapshots(widget.pollId),
          builder: (
            BuildContext context,
            AsyncSnapshot<QuerySnapshot<Object?>?> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingSpinner();
            }
            if (snapshot.hasError || snapshot.data == null) {
              Future.microtask(() {
                Navigator.of(context).pop();
                Navigator.push(
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
            List<VoteLocationCollection> locationsVotesCollection = [];
            if (snapshot.data!.docs.isNotEmpty) {
              locationsVotesCollection =
                  snapshot.data!.docs.map<VoteLocationCollection>((e) {
                return VoteLocationCollection.fromMap(
                    e.data() as Map<String, dynamic>);
              }).toList();
            }
            for (var location in widget.locations) {
              VoteLocationCollection? voteLocation =
                  locationsVotesCollection.firstWhereOrNull(
                      (element) => element.locationName == location["name"]);
              if (voteLocation == null) {
                locationsVotesCollection.add(
                  VoteLocationCollection(
                    locationName: location["name"],
                    pollId: widget.pollId,
                    votes: {
                      widget.organizerUid: Availability.yes,
                    },
                  ),
                );
              } else {
                voteLocation.votes[widget.organizerUid] = Availability.yes;
              }
            }
            if (sortedByVotes) {
              locationsVotesCollection.sort((a, b) =>
                  b.getPositiveVotes().length - a.getPositiveVotes().length);
            } else {
              locationsVotesCollection
                  .sort((a, b) => a.votes.length - b.votes.length);
            }
            return Column(
              children: locationsVotesCollection.map((voteLocation) {
                var location = widget.locations.firstWhere(
                  (element) => element["name"] == voteLocation.locationName,
                );
                return LocationTile2(
                  pollId: widget.pollId,
                  organizerUid: widget.organizerUid,
                  invites: widget.invites,
                  location: Location(
                    location["name"],
                    location["desc"],
                    location["site"],
                    location["lat"],
                    location["lon"],
                  ),
                  voteLocation: voteLocation,
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class LocationTile2 extends StatelessWidget {
  final String pollId;
  final String organizerUid;
  final List<PollEventInviteCollection> invites;
  final Location location;
  final VoteLocationCollection voteLocation;
  const LocationTile2({
    super.key,
    required this.pollId,
    required this.organizerUid,
    required this.invites,
    required this.location,
    required this.voteLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 1,
            color: Palette.greyColor,
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
            color: Palette.lightBGColor,
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            Icons.location_on_outlined,
            color: Palette.greyColor,
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
        onTap: () {
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
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
*/