import 'package:dima_app/providers/preferences.dart';
import 'package:dima_app/screens/poll_detail/creator_options.dart';
import 'package:dima_app/screens/poll_detail/dates_list.dart';
import 'package:dima_app/screens/poll_detail/invitees_pill.dart';
import 'package:dima_app/screens/poll_detail/locations_list.dart';
import 'package:dima_app/server/date_methods.dart';
import 'package:dima_app/server/firebase_poll_event.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/tables/poll_event_collection.dart';
import 'package:dima_app/server/tables/poll_event_invite_collection.dart';
import 'package:dima_app/server/tables/vote_date_collection.dart';
import 'package:dima_app/server/tables/vote_location_collection.dart';
import 'package:dima_app/themes/layout_constants.dart';
import 'package:dima_app/widgets/delay_widget.dart';
import 'package:dima_app/widgets/loading_overlay.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:dima_app/widgets/tabbar_switcher.dart';
import 'package:dima_app/widgets/user_list.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class PollDetailScreen extends StatelessWidget {
  final String pollId;
  final PollEventCollection pollData;
  final List<PollEventInviteCollection> pollInvites;
  final List<VoteLocationCollection> votesLocations;
  final List<VoteDateCollection> votesDates;
  final VoidCallback refreshPollDetail;
  const PollDetailScreen({
    super.key,
    required this.pollId,
    required this.pollData,
    required this.pollInvites,
    required this.votesLocations,
    required this.votesDates,
    required this.refreshPollDetail,
  });

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
    var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;

    String aboutEventText = pollData.pollEventDesc.isEmpty
        ? "The organizer did not provide any description"
        : pollData.pollEventDesc;

    double lines =
        textSize(aboutEventText, Theme.of(context).textTheme.bodyLarge!).width /
            MediaQuery.of(context).size.width;
    lines *= 2;
    lines += 1;
    double descPadding =
        lines * Theme.of(context).textTheme.bodyLarge!.fontSize!;

    lines = textSize(pollData.pollEventName,
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
              pollData.pollEventName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
            ),
            Center(
              child: InviteesPill(
                pollData: pollData,
                pollEventId: pollId,
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
                DateFormat(Preferences.getBool('is24Hour')
                        ? "MMMM dd yyyy, EEEE 'at' HH:mm"
                        : "MMMM dd yyyy, EEEE 'at' hh:mm a")
                    .format(
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
      appBarTitle: pollData.pollEventName,
      upRightActions: pollData.organizerUid != curUid && !pollData.canInvite
          ? [
              Container(
                margin: const EdgeInsets.only(
                  right: LayoutConstants.kHorizontalPadding,
                ),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  child: Ink(
                    decoration: const BoxDecoration(shape: BoxShape.circle),
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
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: const Icon(
                        Icons.more_horiz,
                      ),
                    ),
                    onTap: () async {
                      var ris = await MyModal.show(
                        context: context,
                        child: CreatorOptions(
                          pollData: pollData,
                          pollEventId: pollId,
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
                        // ignore: use_build_context_synchronously
                        await Provider.of<FirebasePollEvent>(context,
                                listen: false)
                            .closePoll(
                          context: context,
                          pollId: pollId,
                        );
                        /*
                        Widget newScreen = EventDetailCreate(
                          eventId: pollId,
                        );
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pushReplacement(
                          ScreenTransition(
                            builder: (context) => newScreen,
                          ),
                        );
                        */
                      } else if (ris == "delete_poll_$curUid") {
                        // ignore: use_build_context_synchronously
                        Navigator.pop(
                          context,
                          "delete_poll_${pollData.organizerUid}",
                        );
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
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: const Icon(
                      Icons.share_outlined,
                    ),
                  ),
                  onTap: () async {
                    LoadingOverlay.show(context);
                    String url =
                        "https://eventy.page.link?pollId=${pollData.pollEventName}_${pollData.organizerUid}";
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
                    final dynamicLongLink = await FirebaseDynamicLinks.instance
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
                    decoration: const BoxDecoration(shape: BoxShape.circle),
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
          pollId: pollId,
          locations: pollData.locations,
          invites: pollInvites,
          votesLocations: votesLocations,
        ),
        DelayWidget(
          child: DatesList(
            organizerUid: pollData.organizerUid,
            pollId: pollId,
            deadline: pollData.deadline,
            dates: pollData.dates,
            invites: pollInvites,
            votesDates: votesDates,
          ),
        ),
      ],
    );
  }
}
