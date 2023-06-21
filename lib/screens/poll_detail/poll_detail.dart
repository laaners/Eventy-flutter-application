import 'package:dima_app/constants/layout_constants.dart';
import 'package:dima_app/constants/preferences.dart';
import 'package:dima_app/models/poll_event_invite_model.dart';
import 'package:dima_app/models/poll_event_model.dart';
import 'package:dima_app/models/vote_date_model.dart';
import 'package:dima_app/models/vote_location_model.dart';
import 'package:dima_app/screens/poll_detail/components/poll_event_options.dart';
import 'package:dima_app/screens/poll_detail/components/locations_list.dart';
import 'package:dima_app/screens/poll_detail/components/most_voted_date_tile.dart';
import 'package:dima_app/screens/poll_detail/components/most_voted_location_tile.dart';
import 'package:dima_app/services/clock_manager.dart';
import 'package:dima_app/services/date_methods.dart';
import 'package:dima_app/services/firebase_poll_event.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/delay_widget.dart';
import 'package:dima_app/widgets/loading_overlay.dart';
import 'package:dima_app/widgets/my_icon_button.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:dima_app/widgets/tabbar_switcher.dart';
import 'package:dima_app/widgets/user_tile.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'components/dates_list.dart';
import 'components/invitees_pill.dart';

class PollDetailScreen extends StatelessWidget {
  final String pollId;
  final PollEventModel pollData;
  final List<PollEventInviteModel> pollInvites;
  final List<VoteLocationModel> votesLocations;
  final List<VoteDateModel> votesDates;
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

    bool isClosed = pollData.isClosed ||
        DateFormatter.string2DateTime(pollData.deadline)
            .isBefore(DateTime.now());

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
            const SizedBox(height: 10),
            Center(
              child: InviteesPill(
                pollData: pollData,
                pollEventId: pollId,
                invites: pollInvites,
                votesLocations: votesLocations,
                votesDates: votesDates,
                refreshPollDetail: refreshPollDetail,
                isClosed: isClosed,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Organized by",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            UserTileFromUid(userUid: pollData.organizerUid),
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
              isClosed ? "The poll has been closed" : "Last day to vote",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            isClosed
                ? Text(
                    "The most voted options are:",
                    style: Theme.of(context).textTheme.bodyLarge,
                  )
                : Flexible(
                    child: Text(
                      DateFormat(Provider.of<ClockManager>(context).clockMode
                              ? "MMMM dd yyyy, EEEE 'at' HH:mm"
                              : "MMMM dd yyyy, EEEE 'at' hh:mm a")
                          .format(
                        DateFormatter.string2DateTime(pollData.deadline),
                      ),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
            if (isClosed)
              MostVotedLocationTile(
                votesLocations: votesLocations,
                pollData: pollData,
                pollId: pollId,
                invites: pollInvites,
              ),
            if (isClosed)
              MostVotedDateTile(
                votesDates: votesDates,
                pollData: pollData,
                pollId: pollId,
                invites: pollInvites,
              ),
          ],
        ),
      ),
      stickyHeight: 350 + titlePadding + descPadding + (isClosed ? 155 : 0),
      labels: const ["Locations", "Dates"],
      appBarTitle: pollData.pollEventName,
      upRightActions: [
        MyIconButton(
          icon: const Icon(
            Icons.more_vert,
          ),
          onTap: () async {
            var ris = await MyModal.show(
              context: context,
              child: PollEventOptions(
                pollData: pollData,
                pollEventId: pollId,
                invites: pollInvites,
                refreshPollDetail: refreshPollDetail,
                votesLocations: votesLocations,
                votesDates: votesDates,
                isClosed: isClosed,
              ),
              heightFactor: 0.32,
              doneCancelMode: false,
              onDone: () {},
              title: "",
            );
            if (ris == "create_event_$curUid") {
              // ignore: use_build_context_synchronously
              LoadingOverlay.show(context);
              // ignore: use_build_context_synchronously
              await Provider.of<FirebasePollEvent>(context, listen: false)
                  .closePoll(pollId: pollId);
              // ignore: use_build_context_synchronously
              LoadingOverlay.hide(context);
            } else if (ris == "delete_poll_$curUid") {
              // ignore: use_build_context_synchronously
              Navigator.pop(
                context,
                "delete_poll_${pollData.organizerUid}",
              );
            } else if (ris == "exit_poll") {
              // ignore: use_build_context_synchronously
              Navigator.pop(
                context,
                "exit_poll",
              );
            }
          },
        ),
        MyIconButton(
          margin: const EdgeInsets.only(
              right: LayoutConstants.kModalHorizontalPadding),
          icon: const Icon(Icons.refresh),
          onTap: refreshPollDetail,
        ),
      ],
      tabbars: [
        LocationsList(
          isClosed: isClosed,
          votingUid: curUid,
          organizerUid: pollData.organizerUid,
          pollId: pollId,
          locations: pollData.locations,
          invites: pollInvites,
          votesLocations: votesLocations,
        ),
        DelayWidget(
          child: DatesList(
            isClosed: isClosed,
            organizerUid: pollData.organizerUid,
            pollId: pollId,
            deadline: pollData.deadline,
            votingUid: curUid,
            dates: pollData.dates,
            invites: pollInvites,
            votesDates: votesDates,
          ),
        ),
      ],
    );
  }
}
