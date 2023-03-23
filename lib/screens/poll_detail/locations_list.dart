import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/screens/error.dart';
import 'package:dima_app/screens/poll_detail/location_detail.dart';
import 'package:dima_app/server/firebase_vote.dart';
import 'package:dima_app/server/tables/availability.dart';
import 'package:dima_app/server/tables/location.dart';
import 'package:dima_app/server/tables/poll_event_invite_collection.dart';
import 'package:dima_app/server/tables/vote_location_collection.dart';
import 'package:dima_app/themes/palette.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/loading_spinner.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/my_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class LocationsList extends StatefulWidget {
  final String organizerUid;
  final String pollId;
  final List<Map<String, dynamic>> locations;
  final List<PollEventInviteCollection> invites;
  const LocationsList({
    super.key,
    required this.locations,
    required this.pollId,
    required this.organizerUid,
    required this.invites,
  });

  @override
  State<LocationsList> createState() => _LocationsListState();
}

class _LocationsListState extends State<LocationsList> {
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
              VoteLocationCollection? voteLocationCollection =
                  locationsVotesCollection.firstWhereOrNull(
                      (element) => element.locationName == location["name"]);
              if (voteLocationCollection == null) {
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
                voteLocationCollection.votes[widget.organizerUid] =
                    Availability.yes;
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
              children: locationsVotesCollection.map((voteLocationCollection) {
                var location = widget.locations.firstWhere(
                  (element) =>
                      element["name"] == voteLocationCollection.locationName,
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
                  voteLocationCollection: voteLocationCollection,
                );
              }).toList(),
            );
          },
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
  final VoteLocationCollection voteLocationCollection;
  const LocationTile({
    super.key,
    required this.pollId,
    required this.organizerUid,
    required this.invites,
    required this.location,
    required this.voteLocationCollection,
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
            Text((voteLocationCollection.getPositiveVotes().length).toString()),
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
