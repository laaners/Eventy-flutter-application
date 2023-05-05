// ignore_for_file: use_build_context_synchronously

import 'package:dima_app/providers/preferences.dart';
import 'package:dima_app/screens/event_create/my_stepper.dart';
import 'package:dima_app/screens/event_create/step_basics.dart';
import 'package:dima_app/screens/event_create/step_dates.dart';
import 'package:dima_app/screens/event_create/step_invite.dart';
import 'package:dima_app/screens/event_create/step_places.dart';
import 'package:dima_app/server/date_methods.dart';
import 'package:dima_app/server/firebase_poll_event.dart';
import 'package:dima_app/server/firebase_poll_event_invite.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/tables/location.dart';
import 'package:dima_app/server/tables/user_collection.dart';
import 'package:dima_app/widgets/loading_overlay.dart';
import 'package:dima_app/widgets/my_alert_dialog.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
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
    if (Preferences.getBool("is24Hour")) {
      deadlineController.text = DateFormat("yyyy-MM-dd HH:00:00").format(
        DateTime(now.year, now.month, now.day + 1),
      );
    } else {
      deadlineController.text = DateFormat("yyyy-MM-dd hh:00:00 a").format(
        DateTime(now.year, now.month, now.day + 1),
      );
    }
  }

  List<MyStep> stepList() => [
        MyStep(
          isActive: _activeStepIndex >= 0,
          title: const Text(""),
          label: const Text(
            "Basics",
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
          label: const Text(
            "Places",
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
          label: const Text(
            "Dates",
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
          label: const Text(
            "Invite",
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

  Future onStepContinue() async {
    if (_activeStepIndex < (stepList().length - 1)) {
      setState(() {
        _activeStepIndex += 1;
      });
    } else {
      await checkAndCreatePoll();
    }
  }

  Future checkAndCreatePoll() async {
    var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    bool ret = MyAlertDialog.showAlertIfCondition(
      context: context,
      condition: eventTitleController.text.isEmpty,
      title: "Missing Event Name",
      content: "You must give a name to the event",
    );
    if (ret) {
      setState(() {
        _activeStepIndex = 0;
      });
      return;
    }

    ret = MyAlertDialog.showAlertIfCondition(
      context: context,
      condition: locations.isEmpty,
      title: "Missing event places",
      content: "You must choose where to hold the event",
    );
    if (ret) {
      setState(() {
        _activeStepIndex = 1;
      });
      return;
    }

    ret = MyAlertDialog.showAlertIfCondition(
      context: context,
      condition: dates.isEmpty,
      title: "Missing event dates",
      content: "You must choose when to hold the event",
    );
    if (ret) {
      setState(() {
        _activeStepIndex = 2;
      });
      return;
    }

    var locationsMap = locations.map((location) {
      return {
        "name": location.name,
        "site": location.site,
        "lat": location.lat,
        "lon": location.lon,
        "icon": location.icon,
      };
    }).toList();

    /*
    // get event will return NOT NULL if the event ALREADY EXISTS
    var dbEvent =
        await Provider.of<FirebaseEvent>(context, listen: false).getEventData(
      context: context,
      id: "${eventTitleController.text}_$curUid",
    );
    ret = MyAlertDialog.showAlertIfCondition(
      context: context,
      condition: dbEvent != null,
      title: "Duplicate Event",
      content: "An event with this name already exists",
    );
    if (ret) {
      LoadingOverlay.hide(context);
      setState(() {
        _activeStepIndex = 0;
      });
      return;
    }
    */

    LoadingOverlay.show(context);
    var dbPoll =
        await Provider.of<FirebasePollEvent>(context, listen: false).createPoll(
      context: context,
      pollEventName: eventTitleController.text,
      organizerUid: curUid,
      pollEventDesc: eventDescController.text,
      deadline: deadlineController.text,
      dates: dates,
      locations: locationsMap,
      public: visibility,
      canInvite: canInvite,
      isClosed: false,
    );

    // poll create will return NULL if the poll ALREADY EXISTS
    ret = MyAlertDialog.showAlertIfCondition(
      context: context,
      condition: dbPoll == null,
      title: "Duplicate Poll",
      content: "A poll or event with this name already exists",
    );
    if (ret) {
      LoadingOverlay.hide(context);
      setState(() {
        _activeStepIndex = 0;
      });
      return;
    }

    String pollId = "${eventTitleController.text}_$curUid";
    await Provider.of<FirebasePollEventInvite>(context, listen: false)
        .createPollEventInvite(
      context: context,
      pollEventId: pollId,
      inviteeId: curUid,
    );
    await Future.wait(invitees
        .map((invitee) =>
            Provider.of<FirebasePollEventInvite>(context, listen: false)
                .createPollEventInvite(
              context: context,
              pollEventId: pollId,
              inviteeId: invitee.uid,
            ))
        .toList());
    LoadingOverlay.hide(context);
    Navigator.pop(context, pollId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: "New Event",
        upRightActions: [
          TextButton(
            onPressed: () async {
              await checkAndCreatePoll();
            },
            child: const Icon(
              Icons.done,
            ),
          )
        ],
      ),
      body: ResponsiveWrapper(
        child: MyStepper(
          currentStep: _activeStepIndex,
          steps: stepList(),
          onStepTapped: (int index) {
            setState(() {
              _activeStepIndex = index;
            });
          },
          // override continue cancel of stepper
          controlsBuilder: (context, controls) {
            return Container();
          },
        ),
      ),
      /*
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(
          bottom: 10,
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
                  onPressed: () {
                    if (_activeStepIndex == 0) {
                      return;
                    }
                    setState(() {
                      _activeStepIndex -= 1;
                    });
                  },
                ),
              ),
            SizedBox(
              width: _activeStepIndex > 0 ? 10 : 0,
            ),
            Expanded(
              child: MyButton(
                onPressed: onStepContinue,
                text: (_activeStepIndex == stepList().length - 1)
                    ? 'Create'
                    : 'Next',
              ),
            ),
          ],
        ),
      ),
      */
    );
  }
}
