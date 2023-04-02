// ignore_for_file: use_build_context_synchronously

import 'package:dima_app/providers/theme_switch.dart';
import 'package:dima_app/screens/event_create/my_stepper.dart';
import 'package:dima_app/screens/event_create/step_basics.dart';
import 'package:dima_app/screens/event_create/step_dates.dart';
import 'package:dima_app/screens/event_create/step_invite.dart';
import 'package:dima_app/screens/event_create/step_places.dart';
import 'package:dima_app/screens/poll_detail/index.dart';
import 'package:dima_app/server/date_methods.dart';
import 'package:dima_app/server/firebase_poll.dart';
import 'package:dima_app/server/firebase_poll_event_invite.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/tables/location.dart';
import 'package:dima_app/server/tables/user_collection.dart';
import 'package:dima_app/themes/palette.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/loading_overlay.dart';
import 'package:dima_app/widgets/my_alert_dialog.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/my_button.dart';
import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class EventCreateScreen extends StatefulWidget {
  const EventCreateScreen({super.key});

  @override
  State<EventCreateScreen> createState() => _EventCreateScreenState();
}

class _EventCreateScreenState extends State<EventCreateScreen> {
  int _activeStepIndex = 0;

  // stepBasics
  TextEditingController eventTitleController = TextEditingController();
  TextEditingController eventDescController = TextEditingController();
  TextEditingController deadlineController = TextEditingController();
  bool visibility = false;
  bool canInvite = false;

  // stepPlaces
  List<Location> locations = [];

  // stepDates;
  Map<String, dynamic> dates = {};

  // stepInvite
  List<UserCollection> invitees = [];

  @override
  void dispose() {
    super.dispose();
    eventTitleController.dispose();
    eventDescController.dispose();
    deadlineController.dispose();
  }

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    deadlineController.text = DateFormat("yyyy-MM-dd HH:00:00").format(
      DateTime(now.year, now.month, now.day + 1),
    );
  }

  List<MyStep> stepList() => [
        MyStep(
          isActive: _activeStepIndex >= 0,
          title: const Text(""),
          label: Text(
            "Basics",
            style: TextStyle(
              color: Provider.of<ThemeSwitch>(context, listen: false)
                  .themeData
                  .primaryColor,
            ),
          ),
          content: Container(
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: StepBasics(
              eventTitleController: eventTitleController,
              eventDescController: eventDescController,
              deadlineController: deadlineController,
              dates: dates,
              removeDays: (List<String> toRemove) {
                setState(() {
                  dates.forEach((day, slots) {
                    if (slots.isEmpty) {
                      toRemove.add(day);
                    }
                  });
                  dates.removeWhere((key, value) => toRemove.contains(key));
                });
              },
              setDeadline: (DateTime pickedDate) {
                setState(() {
                  deadlineController.text =
                      DateFormatter.dateTime2String(pickedDate);
                });
              },
              visibility: visibility,
              changeVisibility: () {
                setState(() {
                  visibility = !visibility;
                });
              },
              canInvite: canInvite,
              changeCanInvite: () {
                setState(() {
                  canInvite = !canInvite;
                });
              },
            ),
          ),
        ),
        MyStep(
          isActive: _activeStepIndex >= 1,
          title: const Text(""),
          label: Text(
            "Places",
            style: TextStyle(
              color: Provider.of<ThemeSwitch>(context, listen: false)
                  .themeData
                  .primaryColor,
            ),
          ),
          content: StepPlaces(
            locations: locations,
            addLocation: (location) {
              setState(() {
                locations.add(location);
                locations.sort((a, b) => a.name.compareTo(b.name));
              });
            },
            removeLocation: (locationName) {
              setState(() {
                locations.removeWhere((item) => item.name == locationName);
              });
            },
          ),
        ),
        MyStep(
          isActive: _activeStepIndex >= 2,
          title: const Text(""),
          label: Text(
            "Dates",
            style: TextStyle(
              color: Provider.of<ThemeSwitch>(context, listen: false)
                  .themeData
                  .primaryColor,
            ),
          ),
          content: StepDates(
            dates: dates,
            addDate: (value) {
              setState(() {
                String day = value[0];
                String slot = value[1];
                // dates.add(value);
                if (!dates.containsKey(day)) {
                  dates[day] = {};
                }
                dates[day][slot] = 1;
              });
            },
            removeDate: (value) {
              setState(() {
                String day = value[0];
                String slot = value[1];
                // dates.add(value);
                if (dates.containsKey(day)) {
                  if (slot == "all") {
                    dates.removeWhere((key, value) => key == day);
                  } else {
                    if (dates[day].containsKey(slot)) {
                      dates[day].removeWhere((key, value) => key == slot);
                    }
                  }
                }
              });
            },
            removeEmpty: () {
              setState(() {
                List<String> toRemove = [];
                dates.forEach((day, slots) {
                  if (slots.isEmpty) {
                    toRemove.add(day);
                  }
                });
                dates.removeWhere((key, value) => toRemove.contains(key));
              });
            },
            deadlineController: deadlineController,
          ),
        ),
        MyStep(
          isActive: _activeStepIndex >= 3,
          title: const Text(""),
          label: Text(
            "Invite",
            style: TextStyle(
              color: Provider.of<ThemeSwitch>(context, listen: false)
                  .themeData
                  .primaryColor,
            ),
          ),
          content: StepInvite(
            organizerUid:
                Provider.of<FirebaseUser>(context, listen: false).user!.uid,
            invitees: invitees,
            addInvitee: (UserCollection user) {
              setState(() {
                if (!invitees.map((_) => _.uid).toList().contains(user.uid)) {
                  // inviteeIds.add(uid);
                  invitees.insert(0, user);
                }
              });
            },
            removeInvitee: (UserCollection user) {
              setState(() {
                invitees.removeWhere((item) => item.uid == user.uid);
              });
            },
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: "New Event",
        upRightActions: [MyAppBar.SearchAction(context)],
      ),
      body: ResponsiveWrapper(
        child: Theme(
          data: ThemeData(
            canvasColor: Provider.of<ThemeSwitch>(context)
                .themeData
                .scaffoldBackgroundColor,
            shadowColor: Colors.transparent,
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Palette.blueColor,
                ),
          ),
          child: MyStepper(
            currentStep: _activeStepIndex,
            steps: stepList(),
            onStepContinue: () async {
              if (_activeStepIndex < (stepList().length - 1)) {
                setState(() {
                  _activeStepIndex += 1;
                });
              } else {
                var curUid =
                    Provider.of<FirebaseUser>(context, listen: false).user!.uid;
                bool ret = MyAlertDialog.showAlertIfCondition(
                  context,
                  eventTitleController.text.isEmpty,
                  "MISSING EVENT NAME",
                  "You must give a name to the event",
                );
                if (ret) return;

                ret = MyAlertDialog.showAlertIfCondition(
                  context,
                  locations.isEmpty,
                  "MISSING EVENT PLACES",
                  "You must choose where to hold the event",
                );
                if (ret) return;

                ret = MyAlertDialog.showAlertIfCondition(
                  context,
                  dates.isEmpty,
                  "MISSING EVENT DATES",
                  "You must choose when to hold the event",
                );
                if (ret) return;

                var utcDeadline =
                    DateFormatter.toUtcString(deadlineController.text);
                Map<String, dynamic> utcDates = {};
                dates.forEach((day, slots) {
                  slots.forEach((slot, _) {
                    var startDateString =
                        "${day.split(" ")[0]} ${slot.split("-")[0]}:00";
                    var endDateString =
                        "${day.split(" ")[0]} ${slot.split("-")[1]}:00";
                    var startDateUtc = DateFormatter.string2DateTime(
                        DateFormatter.toUtcString(startDateString));
                    var endDateUtc = DateFormatter.string2DateTime(
                        DateFormatter.toUtcString(endDateString));
                    String utcDay =
                        DateFormat("yyyy-MM-dd").format(startDateUtc);
                    var startUtc = DateFormat("HH:mm").format(startDateUtc);
                    var endUtc = DateFormat("HH:mm").format(endDateUtc);
                    if (!utcDates.containsKey(utcDay)) {
                      utcDates[utcDay] = [];
                    }
                    utcDates[utcDay].add({
                      "start": startUtc,
                      "end": endUtc,
                    });
                  });
                });
                var locationsMap = locations.map((location) {
                  return {
                    "name": location.name,
                    "site": location.site,
                    "lat": location.lat,
                    "lon": location.lon,
                    "icon": location.icon,
                  };
                }).toList();
                LoadingOverlay.show(context);
                var dbPoll =
                    await Provider.of<FirebasePoll>(context, listen: false)
                        .createPoll(
                  context: context,
                  pollName: eventTitleController.text,
                  organizerUid: curUid,
                  pollDesc: eventDescController.text,
                  deadline: utcDeadline,
                  dates: utcDates,
                  locations: locationsMap,
                  public: visibility,
                  canInvite: canInvite,
                );
                ret = MyAlertDialog.showAlertIfCondition(
                  context,
                  dbPoll == null,
                  "DUPLICATE POLL",
                  "A poll with this name already exists",
                );
                if (ret) {
                  LoadingOverlay.hide(context);
                  return;
                }

                String pollId = "${eventTitleController.text}_$curUid";
                await Provider.of<FirebasePollEventInvite>(context,
                        listen: false)
                    .createPollEventInvite(
                  context: context,
                  pollEventId: pollId,
                  inviteeId: curUid,
                );
                await Future.wait(invitees
                    .map((invitee) => Provider.of<FirebasePollEventInvite>(
                                context,
                                listen: false)
                            .createPollEventInvite(
                          context: context,
                          pollEventId: pollId,
                          inviteeId: invitee.uid,
                        ))
                    .toList());
                LoadingOverlay.hide(context);
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  ScreenTransition(
                      builder: (context) => PollDetailScreen(pollId: pollId)),
                );
              }
            },
            onStepCancel: () {
              if (_activeStepIndex == 0) {
                return;
              }
              setState(() {
                _activeStepIndex -= 1;
              });
            },
            onStepTapped: (int index) {
              setState(() {
                _activeStepIndex = index;
              });
            },
            // override continue cancel of stepper
            controlsBuilder: (context, controls) {
              final isLastStep = _activeStepIndex == stepList().length - 1;
              return Container(
                margin: const EdgeInsets.only(
                  bottom: 0,
                  top: 10,
                  left: 10,
                  right: 10,
                ),
                child: Row(
                  children: [
                    if (_activeStepIndex > 0)
                      Expanded(
                        child: MyButton(
                          text: "Back",
                          onPressed: controls.onStepCancel!,
                        ),
                      ),
                    SizedBox(
                      width: _activeStepIndex > 0 ? 10 : 0,
                    ),
                    Expanded(
                      child: MyButton(
                        onPressed: controls.onStepContinue!,
                        text: (isLastStep) ? 'Create' : 'Next',
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
