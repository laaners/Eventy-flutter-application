import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/screens/error.dart';
import 'package:dima_app/screens/event_detail/event_detail_create.dart';
import 'package:dima_app/screens/poll_detail/creator_options.dart';
import 'package:dima_app/screens/poll_detail/dates_list.dart';
import 'package:dima_app/screens/poll_detail/invitees_pill.dart';
import 'package:dima_app/screens/poll_detail/locations_list.dart';
import 'package:dima_app/server/date_methods.dart';
import 'package:dima_app/server/firebase_poll.dart';
import 'package:dima_app/server/firebase_poll_event_invite.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/firebase_vote.dart';
import 'package:dima_app/server/tables/availability.dart';
import 'package:dima_app/server/tables/poll_collection.dart';
import 'package:dima_app/server/tables/poll_event_invite_collection.dart';
import 'package:dima_app/server/tables/vote_date_collection.dart';
import 'package:dima_app/server/tables/vote_location_collection.dart';
import 'package:dima_app/themes/layout_constants.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/delay_widget.dart';
import 'package:dima_app/widgets/loading_overlay.dart';
import 'package:dima_app/widgets/loading_spinner.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:dima_app/widgets/tabbar_switcher.dart';
import 'package:dima_app/widgets/user_list.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class PollDetailScreen extends StatefulWidget {
  final String pollId;

  const PollDetailScreen({
    super.key,
    required this.pollId,
  });

  @override
  State<PollDetailScreen> createState() => _PollDetailScreenState();
}

class _PollDetailScreenState extends State<PollDetailScreen>
    with AutomaticKeepAliveClientMixin {
  Future<Map<String, dynamic>?>? _future;
  bool _refresh = true;

  Future<Map<String, dynamic>?> getPollDataAndInvites(
      BuildContext context) async {
    try {
      PollCollection? pollData =
          await Provider.of<FirebasePoll>(context, listen: false)
              .getPollData(context, widget.pollId);
      if (pollData == null) return null;
      List<PollEventInviteCollection> pollInvites =
          // ignore: use_build_context_synchronously
          await Provider.of<FirebasePollEventInvite>(context, listen: false)
              .getInvitesFromPollEventId(context, widget.pollId);
      if (pollInvites.isEmpty) return null;

      List<VoteLocationCollection> votesLocations =
          await Future.wait(pollData.locations.map((location) {
        return Provider.of<FirebaseVote>(context, listen: false)
            .getVotesLocation(context, widget.pollId, location["name"])
            .then((value) {
          if (value != null) {
            value.votes[pollData.organizerUid] = Availability.yes;
            return value;
          } else {
            return VoteLocationCollection(
              locationName: location["name"],
              pollId: widget.pollId,
              votes: {
                pollData.organizerUid: Availability.yes,
              },
            );
          }
        });
      }).toList());

      List<Future<VoteDateCollection>> promises = pollData.dates.keys
          .map((date) {
            return pollData.dates[date].map((slot) {
              return Provider.of<FirebaseVote>(context, listen: false)
                  .getVotesDate(
                      context, widget.pollId, date, slot["start"], slot["end"])
                  .then((value) {
                if (value != null) {
                  value.votes[pollData.organizerUid] = Availability.yes;
                  return value;
                } else {
                  return VoteDateCollection(
                    pollId: widget.pollId,
                    date: date,
                    start: slot["start"],
                    end: slot["end"],
                    votes: {
                      pollData.organizerUid: Availability.yes,
                    },
                  );
                }
              });
            }).toList();
          })
          .toList()
          .expand((x) => x)
          .toList()
          .cast();

      List<VoteDateCollection> votesDates = await Future.wait(promises);
      return {
        "data": pollData,
        "invites": pollInvites,
        "locations": votesLocations,
        "dates": votesDates,
      };
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  initState() {
    super.initState();
    _future = getPollDataAndInvites(context);
  }

  void refreshPollDetail() {
    setState(() {
      _future = null;
      _future = getPollDataAndInvites(context);
      _refresh = !_refresh;
    });
  }

  Size textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1,
        textDirection: ui.TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    return StreamBuilder(
      stream: Provider.of<FirebasePollEventInvite>(context, listen: false)
          .getPollEventInviteSnapshot(context, widget.pollId, curUid),
      builder: (
        BuildContext context,
        AsyncSnapshot<DocumentSnapshot<Object?>> snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingSpinner();
        }
        if (snapshot.hasError) {
          Future.microtask(() {
            Navigator.of(context, rootNavigator: false).pushReplacement(
              ScreenTransition(
                builder: (context) => ErrorScreen(
                  errorMsg: snapshot.error.toString(),
                ),
              ),
            );
          });
          return Container();
        }
        if (!snapshot.data!.exists) {
          Future.microtask(() {
            Navigator.of(context, rootNavigator: false).pushReplacement(
              ScreenTransition(
                builder: (context) => ErrorScreen(
                  errorMsg: snapshot.error.toString(),
                ),
              ),
            );
          });
          return Container();
        }
        return FutureBuilder<Map<String, dynamic>?>(
          future: _future,
          builder: (
            BuildContext context,
            AsyncSnapshot<Map<String, dynamic>?> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingSpinner();
            }
            if (snapshot.hasError || !snapshot.hasData) {
              Future.microtask(() {
                Navigator.of(context, rootNavigator: false).pushReplacement(
                  ScreenTransition(
                    builder: (context) => ErrorScreen(
                      errorMsg: snapshot.error.toString(),
                    ),
                  ),
                );
              });
              return Container();
            }
            PollCollection pollData = snapshot.data!["data"];
            List<PollEventInviteCollection> pollInvites =
                snapshot.data!["invites"];
            List<VoteLocationCollection> votesLocations =
                snapshot.data!["locations"];
            votesLocations.sort((a, b) =>
                b.getPositiveVotes().length - a.getPositiveVotes().length);
            List<VoteDateCollection> votesDates = snapshot.data!["dates"];
            votesDates.sort((a, b) =>
                b.getPositiveVotes().length - a.getPositiveVotes().length);
            var curUid =
                Provider.of<FirebaseUser>(context, listen: false).user!.uid;

            String aboutEventText = pollData.pollDesc.isEmpty
                ? "The organizer did not provide any description"
                : pollData.pollDesc;

            double lines =
                textSize(aboutEventText, Theme.of(context).textTheme.bodyLarge!)
                        .width /
                    MediaQuery.of(context).size.width;
            lines *= 2;
            lines += 1;
            double descPadding =
                lines * Theme.of(context).textTheme.bodyLarge!.fontSize!;

            lines = textSize(pollData.pollName,
                        Theme.of(context).textTheme.headlineMedium!)
                    .width /
                MediaQuery.of(context).size.width;
            lines += 1;
            double titlePadding =
                lines * Theme.of(context).textTheme.headlineMedium!.fontSize!;

            return TabbarSwitcher(
              listSticky: Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pollData.pollName,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                    ),
                    Center(
                      child: InviteesPill(
                        pollData: pollData,
                        pollEventId: widget.pollId,
                        invites: pollInvites,
                        votesLocations: votesLocations,
                        votesDates: votesDates,
                        refreshPollDetail: refreshPollDetail,
                      ),
                    ),
                    Container(padding: const EdgeInsets.symmetric(vertical: 5)),
                    Text(
                      "Organized by",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    UserTile(userUid: pollData.organizerUid),
                    Text(
                      "About this event",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                    ),
                    Flexible(
                      child: Text(
                        aboutEventText,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                    ),
                    Text(
                      "Last day to vote",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                    ),
                    Flexible(
                      child: Text(
                        DateFormat("MMMM dd yyyy, EEEE 'at' hh:mm").format(
                          DateFormatter.string2DateTime(pollData.deadline),
                        ),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
              stickyHeight: 350 + descPadding + titlePadding,
              labels: const ["Locations", "Dates"],
              appBarTitle: pollData.pollName,
              upRightActions: pollData.organizerUid != curUid &&
                      !pollData.canInvite
                  ? [
                      Container(
                        margin: const EdgeInsets.only(
                          right: LayoutConstants.kHorizontalPadding,
                        ),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          child: Ink(
                            decoration:
                                const BoxDecoration(shape: BoxShape.circle),
                            child: const Icon(
                              Icons.refresh,
                            ),
                          ),
                          onTap: () async {
                            refreshPollDetail();
                          },
                        ),
                      ),
                    ]
                  : [
                      if (pollData.organizerUid == curUid)
                        Container(
                          margin: const EdgeInsets.only(
                            right: LayoutConstants.kHorizontalPadding,
                          ),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            child: Ink(
                              decoration:
                                  const BoxDecoration(shape: BoxShape.circle),
                              child: const Icon(
                                Icons.more_horiz,
                              ),
                            ),
                            onTap: () async {
                              var ris = await MyModal.show(
                                context: context,
                                child: CreatorOptions(
                                  pollData: pollData,
                                  pollEventId: widget.pollId,
                                  invites: pollInvites,
                                  refreshPollDetail: refreshPollDetail,
                                  votesLocations: votesLocations,
                                  votesDates: votesDates,
                                ),
                                heightFactor: 0.4,
                                doneCancelMode: true,
                                onDone: () {},
                                title: "",
                              );
                              if (ris == "create_event_$curUid") {
                                Widget newScreen = EventDetailCreate(
                                  eventId: widget.pollId,
                                );
                                // ignore: use_build_context_synchronously
                                Navigator.of(context).pushReplacement(
                                  ScreenTransition(
                                    builder: (context) => newScreen,
                                  ),
                                );
                              } else if (ris == "delete_poll_$curUid") {
                                // ignore: use_build_context_synchronously
                                Navigator.pop(context,
                                    "delete_poll_${pollData.organizerUid}");
                              }
                            },
                          ),
                        ),
                      Container(
                        margin: const EdgeInsets.only(
                          right: LayoutConstants.kHorizontalPadding,
                        ),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          child: Ink(
                            decoration:
                                const BoxDecoration(shape: BoxShape.circle),
                            child: const Icon(
                              Icons.share_outlined,
                            ),
                          ),
                          onTap: () async {
                            LoadingOverlay.show(context);
                            String url =
                                "https://eventy.page.link?pollId=${pollData.pollName}_${pollData.organizerUid}";
                            final dynamicLinkParams = DynamicLinkParameters(
                              link: Uri.parse(url),
                              uriPrefix: "https://eventy.page.link",
                              androidParameters: const AndroidParameters(
                                packageName: "com.example.dima_app",
                              ),
                              iosParameters: const IOSParameters(
                                bundleId: "com.example.dima_app",
                              ),
                            );
                            final dynamicLongLink = await FirebaseDynamicLinks
                                .instance
                                .buildLink(dynamicLinkParams);
                            final ShortDynamicLink dynamicShortLink =
                                await FirebaseDynamicLinks.instance
                                    .buildShortLink(dynamicLinkParams);
                            Uri finalUrl = dynamicShortLink.shortUrl;
                            print(finalUrl);
                            print(dynamicLongLink);
                            await Share.share(finalUrl.toString());
                            LoadingOverlay.hide(context);
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                          right: LayoutConstants.kHorizontalPadding,
                        ),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          child: Ink(
                            decoration:
                                const BoxDecoration(shape: BoxShape.circle),
                            child: const Icon(
                              Icons.refresh,
                            ),
                          ),
                          onTap: () async {
                            refreshPollDetail();
                          },
                        ),
                      ),
                    ],
              tabbars: [
                LocationsList(
                  votingUid: curUid,
                  organizerUid: pollData.organizerUid,
                  pollId: widget.pollId,
                  locations: pollData.locations,
                  invites: pollInvites,
                  votesLocations: votesLocations,
                ),
                DelayWidget(
                  child: DatesList(
                    organizerUid: pollData.organizerUid,
                    pollId: widget.pollId,
                    deadline: pollData.deadline,
                    dates: pollData.dates,
                    invites: pollInvites,
                    votesDates: votesDates,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
