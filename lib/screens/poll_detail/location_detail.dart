import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/providers/theme_switch.dart';
import 'package:dima_app/screens/error.dart';
import 'package:dima_app/screens/poll_detail/my_poll.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/firebase_vote.dart';
import 'package:dima_app/server/tables/availability.dart';
import 'package:dima_app/server/tables/location.dart';
import 'package:dima_app/server/tables/poll_event_invite_collection.dart';
import 'package:dima_app/server/tables/vote_location_collection.dart';
import 'package:dima_app/themes/palette.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/gmaps.dart';
import 'package:dima_app/widgets/loading_spinner.dart';
import 'package:dima_app/widgets/my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class LocationDetail extends StatelessWidget {
  final String pollId;
  final String organizerUid;
  final List<PollEventInviteCollection> invites;
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

  List<MyPollOption> getOptions(VoteLocationCollection? locationCollection) {
    return [
      MyPollOption(
        id: Availability.yes,
        title: const Text(" Present", style: TextStyle(fontSize: 20)),
        votes: locationCollection != null
            ? 1 +
                (locationCollection
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
        title: const Text("If need be", style: TextStyle(fontSize: 20)),
        votes: locationCollection != null
            ? locationCollection
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
        title: const Text("Not present", style: TextStyle(fontSize: 20)),
        votes: locationCollection != null
            ? locationCollection
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
        title: const Text("Pending", style: TextStyle(fontSize: 20)),
        votes: locationCollection != null
            ? locationCollection
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: Container(
                margin: const EdgeInsets.only(bottom: 15, top: 8),
                alignment: Alignment.center,
                width: 80,
                height: 3,
                decoration: BoxDecoration(
                  color: Palette.greyColor.withOpacity(0.5),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: ListView(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 8, top: 8, left: 15),
                  alignment: Alignment.topLeft,
                  child: Text(
                    location.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 8, top: 8, left: 15),
                  alignment: Alignment.topLeft,
                  child: const Text(
                    "Description (optional)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  child: MyTextField(
                    maxLength: 200,
                    maxLines: 6,
                    hintText:
                        "Add details and indications to reach this location",
                    controller: TextEditingController(),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 8, top: 8, left: 15),
                  alignment: Alignment.topLeft,
                  child: const Text(
                    "Votes",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(top: 8)),
                StreamBuilder(
                  stream: Provider.of<FirebaseVote>(context, listen: false)
                      .getVoteLocationSnapshot(context, pollId, location.name),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<DocumentSnapshot<Object?>> snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingSpinner();
                    }
                    if (snapshot.hasError) {
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
                    VoteLocationCollection? locationCollection;
                    var curUid =
                        Provider.of<FirebaseUser>(context, listen: false)
                            .user!
                            .uid;
                    int userVotedOptionId = Availability.empty;
                    if (snapshot.data!.exists) {
                      locationCollection = VoteLocationCollection.fromMap(
                        (snapshot.data!.data()) as Map<String, dynamic>,
                      );
                      userVotedOptionId = locationCollection.votes[curUid] ??
                          Availability.empty;
                    }
                    userVotedOptionId = organizerUid == curUid
                        ? Availability.yes
                        : Availability.empty;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      child: MyPolls(
                        curUid: curUid,
                        organizedUid: organizerUid,
                        votedAnimationDuration: 0,
                        votesText: "",
                        hasVoted: true,
                        userVotedOptionId: userVotedOptionId,
                        heightBetweenTitleAndOptions: 0,
                        pollId: '1',
                        onVoted:
                            (MyPollOption pollOption, int newTotalVotes) async {
                          int newAvailability = pollOption.id!;
                          await Provider.of<FirebaseVote>(context,
                                  listen: false)
                              .userVoteLocation(
                            context,
                            pollId,
                            location.name,
                            curUid,
                            newAvailability,
                          );
                          modifyVote(newAvailability);
                          return true;
                        },
                        pollOptionsSplashColor: Colors.white,
                        votedProgressColor: Colors.grey.withOpacity(0.3),
                        votedBackgroundColor: Colors.grey.withOpacity(0.2),
                        /*
                    votesTextStyle: themeData.textTheme.subtitle1,
                    votedPercentageTextStyle:
                        themeData.textTheme.headline4?.copyWith(
                      color: Colors.black(),
                    ),
                    */
                        votedCheckmark: const Icon(
                          Icons.check,
                          color: Colors.black,
                        ),
                        pollTitle: Container(),
                        pollOptions: getOptions(locationCollection),
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
                /*
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  child: MyPolls(
                    hasVoted: true,
                    userVotedOptionId: userVotedOptionId,
                    heightBetweenTitleAndOptions: 0,
                    pollId: '1',
                    onVoted: (MyPollOption pollOption, int newTotalVotes) async {
                      print('Voted: ${pollOption.id}');
                      print(pollOption.votes);
                      return true;
                    },
                    pollOptionsSplashColor: Colors.white,
                    votedProgressColor: Colors.grey.withOpacity(0.3),
                    votedBackgroundColor: Colors.grey.withOpacity(0.2),
                    /*
                    votesTextStyle: themeData.textTheme.subtitle1,
                    votedPercentageTextStyle:
                        themeData.textTheme.headline4?.copyWith(
                      color: Colors.black(),
                    ),
                    */
                    votedCheckmark: const Icon(
                      Icons.check,
                      color: Colors.black,
                    ),
                    pollTitle: Container(),
                    pollOptions: pollOptions,
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
                ),
                
                */
                const Padding(padding: EdgeInsets.only(top: 8)),
                location.name == "Virtual meeting"
                    ? ListTile(
                        title: const Text(
                          "Virtual room link",
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
                          initialValue: location.site.isEmpty
                              ? "The organizer did not provide any link"
                              : location.site,
                          style: TextStyle(
                            color: Provider.of<ThemeSwitch>(context)
                                .themeData
                                .primaryColor,
                          ),
                          enabled: false,
                          autofocus: false,
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
                              style: TextStyle(
                                color: Provider.of<ThemeSwitch>(context)
                                    .themeData
                                    .primaryColor,
                              ),
                              autofocus: false,
                              enabled: false,
                            ),
                          ),
                          GmapFromCoor(
                            lat: location.lat,
                            lon: location.lon,
                            address: location.site,
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}