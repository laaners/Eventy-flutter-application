import 'package:dima_app/constants/layout_constants.dart';
import 'package:dima_app/constants/preferences.dart';
import 'package:dima_app/models/poll_event_model.dart';
import 'package:dima_app/screens/poll_detail/components/poll_event_options.dart';
import 'package:dima_app/screens/poll_event/poll_event.dart';
import 'package:dima_app/services/date_methods.dart';
import 'package:dima_app/services/firebase_poll_event.dart';
import 'package:dima_app/services/firebase_poll_event_invite.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/loading_overlay.dart';
import 'package:dima_app/widgets/my_icon_button.dart';
import 'package:dima_app/widgets/my_modal.dart';
import 'package:dima_app/widgets/poll_event_tile.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PollEventListBody extends StatefulWidget {
  final List<PollEventModel> events;
  const PollEventListBody({super.key, required this.events});

  @override
  State<PollEventListBody> createState() => _PollEventListBodyState();
}

class _PollEventListBodyState extends State<PollEventListBody> {
  late List<PollEventModel> events;
  bool alphabeticAsc = true;
  bool chronoAsc = true;

  String filter = "All";

  @override
  void initState() {
    super.initState();
    events = widget.events;
    events.sort((a, b) =>
        a.pollEventName.toLowerCase().compareTo(b.pollEventName.toLowerCase()));
    events.sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  // https://github.com/flutter/flutter/issues/20416
  @override
  void didUpdateWidget(PollEventListBody oldWidget) {
    setState(() {
      events = widget.events;
      alphabeticAsc
          ? events.sort((a, b) => a.pollEventName
              .toLowerCase()
              .compareTo(b.pollEventName.toLowerCase()))
          : events.sort((a, b) => b.pollEventName
              .toLowerCase()
              .compareTo(a.pollEventName.toLowerCase()));
      chronoAsc
          ? events.sort((a, b) => a.deadline.compareTo(b.deadline))
          : events.sort((a, b) => b.deadline.compareTo(a.deadline));
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    String curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    return Stack(
      children: [
        Container(
          alignment: Alignment.topRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: ["All", "Open", "Closed"].map((label) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: filter == label
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).focusColor,
                          ),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 10),
                          padding: const EdgeInsets.symmetric(
                              vertical: 3, horizontal: 15),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                switch (label) {
                                  case "All":
                                    events = widget.events;
                                    break;
                                  case "Open":
                                    events = widget.events.where((event) {
                                      bool isClosed = event.isClosed ||
                                          DateFormatter.string2DateTime(
                                                  event.deadline)
                                              .isBefore(DateTime.now());
                                      return !isClosed;
                                    }).toList();
                                    break;
                                  case "Closed":
                                    events = widget.events.where((event) {
                                      bool isClosed = event.isClosed ||
                                          DateFormatter.string2DateTime(
                                                  event.deadline)
                                              .isBefore(DateTime.now());
                                      return isClosed;
                                    }).toList();
                                    break;
                                }
                                filter = label;
                              });
                            },
                            child: Text(
                              label,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color: filter == label
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                  ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyIconButton(
                    icon: const Icon(Icons.sort_by_alpha_outlined),
                    onTap: () {
                      setState(() {
                        alphabeticAsc = !alphabeticAsc;
                        alphabeticAsc
                            ? events.sort((a, b) => a.pollEventName
                                .toLowerCase()
                                .compareTo(b.pollEventName.toLowerCase()))
                            : events.sort((a, b) => b.pollEventName
                                .toLowerCase()
                                .compareTo(a.pollEventName.toLowerCase()));
                      });
                    },
                  ),
                  MyIconButton(
                    icon: const Icon(Icons.access_time_outlined),
                    margin: const EdgeInsets.only(
                        right: LayoutConstants.kHorizontalPadding),
                    onTap: () {
                      setState(() {
                        chronoAsc = !chronoAsc;
                        chronoAsc
                            ? events.sort(
                                (a, b) => a.deadline.compareTo(b.deadline))
                            : events.sort(
                                (a, b) => b.deadline.compareTo(a.deadline));
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 50),
          child: Scrollbar(
            child: ListView.builder(
              itemCount: events.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == events.length) {
                  return Container(height: LayoutConstants.kPaddingFromCreate);
                }
                PollEventModel event = events[index];
                bool isClosed = event.isClosed ||
                    DateFormatter.string2DateTime(event.deadline)
                        .isBefore(DateTime.now());
                return PollEventTile(
                  pollEvent: event,
                  bgColor:
                      isClosed ? Theme.of(context).primaryColorLight : null,
                  locationBanner: event.locations[0].icon,
                  descTop: isClosed
                      ? "Closed poll"
                      : "Poll closes the ${DateFormat(Preferences.getBool('is24Hour') ? "dd/MM/yyyy, 'at' HH:mm" : "dd/MM/yyyy, 'at' hh:mm a").format(
                          DateFormatter.string2DateTime(event.deadline),
                        )}",
                  descMiddle: event.pollEventName,
                  onTap: () async {
                    // ignore: use_build_context_synchronously
                    String pollEventId =
                        "${event.pollEventName}_${event.organizerUid}";
                    Widget newScreen =
                        PollEventScreen(pollEventId: pollEventId);
                    // ignore: use_build_context_synchronously
                    var ris =
                        await Navigator.of(context, rootNavigator: false).push(
                      ScreenTransition(
                        builder: (context) => newScreen,
                      ),
                    );
                    if (ris == "delete_poll_$curUid") {
                      // ignore: use_build_context_synchronously
                      LoadingOverlay.show(context);
                      // ignore: use_build_context_synchronously
                      await Provider.of<FirebasePollEvent>(context,
                              listen: false)
                          .deletePollEvent(
                        context: context,
                        pollId: pollEventId,
                      );
                      // ignore: use_build_context_synchronously
                      LoadingOverlay.hide(context);
                    }
                    if (ris == "exit_poll") {
                      // ignore: use_build_context_synchronously
                      LoadingOverlay.show(context);
                      // ignore: use_build_context_synchronously
                      await Provider.of<FirebasePollEventInvite>(context,
                              listen: false)
                          .deletePollEventInvite(
                        context: context,
                        inviteeId: curUid,
                        pollEventId: pollEventId,
                      );
                      // ignore: use_build_context_synchronously
                      LoadingOverlay.hide(context);
                    }
                  },
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      MyIconButton(
                        icon: const Icon(Icons.more_vert),
                        onTap: () async {
                          String pollEventId =
                              "${event.pollEventName}_${event.organizerUid}";
                          var ris = await MyModal.show(
                            context: context,
                            child: PollEventOptions(
                              pollData: event,
                              pollEventId: pollEventId,
                              invites: [],
                              refreshPollDetail: () {},
                              votesLocations: [],
                              votesDates: [],
                            ),
                            heightFactor: 0.3,
                            doneCancelMode: false,
                            onDone: () {},
                            title: "",
                          );
                          if (ris == "create_event_$curUid") {
                            // ignore: use_build_context_synchronously
                            LoadingOverlay.show(context);
                            // ignore: use_build_context_synchronously
                            await Provider.of<FirebasePollEvent>(context,
                                    listen: false)
                                .closePoll(
                              context: context,
                              pollId: pollEventId,
                            );
                            // ignore: use_build_context_synchronously
                            LoadingOverlay.hide(context);
                          } else if (ris == "delete_poll_$curUid") {
                            // ignore: use_build_context_synchronously
                            LoadingOverlay.show(context);
                            // ignore: use_build_context_synchronously
                            await Provider.of<FirebasePollEvent>(context,
                                    listen: false)
                                .deletePollEvent(
                              context: context,
                              pollId: pollEventId,
                            );
                            // ignore: use_build_context_synchronously
                            LoadingOverlay.hide(context);
                          } else if (ris == "exit_poll") {
                            // ignore: use_build_context_synchronously
                            LoadingOverlay.show(context);
                            // ignore: use_build_context_synchronously
                            await Provider.of<FirebasePollEventInvite>(context,
                                    listen: false)
                                .deletePollEventInvite(
                              context: context,
                              inviteeId: curUid,
                              pollEventId: pollEventId,
                            );
                            // ignore: use_build_context_synchronously
                            LoadingOverlay.hide(context);
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
