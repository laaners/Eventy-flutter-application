import 'package:dima_app/constants/layout_constants.dart';
import 'package:dima_app/models/poll_event_model.dart';
import 'package:dima_app/screens/poll_detail/components/poll_event_options.dart';
import 'package:dima_app/screens/poll_event/poll_event.dart';
import 'package:dima_app/services/clock_manager.dart';
import 'package:dima_app/services/date_methods.dart';
import 'package:dima_app/services/firebase_poll_event.dart';
import 'package:dima_app/services/poll_event_methods.dart';
import 'package:dima_app/widgets/empty_list.dart';
import 'package:dima_app/widgets/my_icon_button.dart';
import 'package:dima_app/widgets/poll_event_tile.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:dima_app/widgets/search_tile.dart';
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

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();

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
      switch (filter) {
        case "All":
          events = widget.events;
          break;
        case "Open":
          events = widget.events.where((event) {
            bool isClosed = event.isClosed ||
                DateFormatter.string2DateTime(event.deadline)
                    .isBefore(DateTime.now());
            return !isClosed;
          }).toList();
          break;
        case "Closed":
          events = widget.events.where((event) {
            bool isClosed = event.isClosed ||
                DateFormatter.string2DateTime(event.deadline)
                    .isBefore(DateTime.now());
            return isClosed;
          }).toList();
          break;
      }
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
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(
            vertical: LayoutConstants.kHorizontalPadding,
            horizontal: 5,
          ),
          child: SearchTile(
            controller: _controller,
            focusNode: _focus,
            hintText: "Search for poll/event name",
            emptySearch: () {
              if (_controller.text.isNotEmpty) {
                setState(() {
                  _controller.text = "";
                });
              }
            },
            onChanged: (text) {
              setState(() {});
            },
          ),
        ),
        Container(
          alignment: Alignment.topRight,
          margin: const EdgeInsets.only(top: 65),
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
                        return InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
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
                          child: Container(
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
          margin: const EdgeInsets.only(top: 115),
          child: Builder(builder: (context) {
            List<PollEventModel> eventsToShow = events
                .where((event) => event.pollEventName
                    .toLowerCase()
                    .contains(_controller.text.toLowerCase()))
                .toList();
            return Scrollbar(
              child: eventsToShow.isEmpty
                  ? ListView(
                      controller: ScrollController(),
                      children: const [
                        EmptyList(emptyMsg: "No polls or events found"),
                      ],
                    )
                  : ListView.builder(
                      itemCount: eventsToShow.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == eventsToShow.length) {
                          return Container(
                              height: LayoutConstants.kPaddingFromCreate);
                        }
                        PollEventModel event = eventsToShow[index];
                        bool isClosed = event.isClosed ||
                            DateFormatter.string2DateTime(event.deadline)
                                .isBefore(DateTime.now());
                        String pollEventId =
                            "${event.pollEventName}_${event.organizerUid}";
                        if (isClosed && !event.isClosed) {
                          // close the event on db
                          Provider.of<FirebasePollEvent>(context, listen: false)
                              .closePoll(pollId: pollEventId, context: context);
                        }
                        return PollEventTile(
                          pollEvent: event,
                          bgColor: isClosed
                              ? Theme.of(context).primaryColorLight
                              : null,
                          locationBanner: event.locations[0].icon,
                          descTop: isClosed
                              ? "Closed poll"
                              : "Poll closes the ${DateFormat(Provider.of<ClockManager>(context).clockMode ? "dd/MM/yyyy, 'at' HH:mm" : "dd/MM/yyyy, 'at' hh:mm a").format(
                                  DateFormatter.string2DateTime(event.deadline),
                                )}",
                          descMiddle: event.pollEventName,
                          onTap: () async {
                            Widget newScreen =
                                PollEventScreen(pollEventId: pollEventId);
                            // ignore: use_build_context_synchronously
                            var ris = await Navigator.of(context,
                                    rootNavigator: false)
                                .push(
                              ScreenTransition(
                                builder: (context) => newScreen,
                              ),
                            );

                            // ignore: use_build_context_synchronously
                            await PollEventUserMethods.optionsRisManager(
                              context: context,
                              pollEventId: pollEventId,
                              ris: ris,
                            );
                          },
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              MyIconButton(
                                icon: const Icon(Icons.more_vert),
                                onTap: () async {
                                  String pollEventId =
                                      "${event.pollEventName}_${event.organizerUid}";
                                  var ris = await showModalBottomSheet(
                                    context: context,
                                    useRootNavigator: true,
                                    builder: (BuildContext context) {
                                      return PollEventOptions(
                                        pollData: event,
                                        pollEventId: pollEventId,
                                        invites: const [],
                                        refreshPollDetail: () {},
                                        votesLocations: const [],
                                        votesDates: const [],
                                        isClosed: isClosed,
                                      );
                                    },
                                  );
                                  // ignore: use_build_context_synchronously
                                  await PollEventUserMethods.optionsRisManager(
                                    context: context,
                                    pollEventId: pollEventId,
                                    ris: ris,
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            );
          }),
        ),
      ],
    );
  }
}
