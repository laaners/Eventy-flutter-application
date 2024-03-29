// ignore_for_file: use_build_context_synchronously

import 'package:dima_app/models/location.dart';
import 'package:dima_app/models/user_model.dart';
import 'package:dima_app/screens/poll_create/components/my_stepper.dart';
import 'package:dima_app/screens/poll_create/components/step_basics.dart';
import 'package:dima_app/screens/poll_create/components/step_dates.dart';
import 'package:dima_app/screens/poll_create/components/step_invite.dart';
import 'package:dima_app/screens/poll_create/components/step_places.dart';
import 'package:dima_app/services/clock_manager.dart';
import 'package:dima_app/services/date_methods.dart';
import 'package:dima_app/services/firebase_poll_event_invite.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/services/firebase_poll_event.dart';
import 'package:dima_app/widgets/loading_overlay.dart';
import 'package:dima_app/widgets/my_alert_dialog.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/my_button.dart';
import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PollCreateScreen extends StatefulWidget {
  const PollCreateScreen({super.key});

  @override
  State<PollCreateScreen> createState() => _PollCreateScreenState();
}

class _PollCreateScreenState extends State<PollCreateScreen> {
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
  List<UserModel> invitees = [];

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
    if (Provider.of<ClockManager>(context, listen: false).clockMode) {
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
          label: const Text("Basics"),
          content: ResponsiveWrapper(
            hideNavigation: true,
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
          label: const Text("Places"),
          content: ResponsiveWrapper(
            hideNavigation: true,
            child: StepPlaces(
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
        ),
        MyStep(
          isActive: _activeStepIndex >= 2,
          title: const Text(""),
          label: const Text("Dates"),
          content: ResponsiveWrapper(
            hideNavigation: true,
            child: StepDates(
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
        ),
        MyStep(
          isActive: _activeStepIndex >= 3,
          title: const Text(""),
          label: const Text("Invite"),
          content: ResponsiveWrapper(
            hideNavigation: true,
            child: Container(
              margin: const EdgeInsets.all(15),
              child: StepInvite(
                organizerUid:
                    Provider.of<FirebaseUser>(context, listen: false).user!.uid,
                invitees: invitees,
                addInvitee: (UserModel user) {
                  setState(() {
                    if (!invitees
                        .map((_) => _.uid)
                        .toList()
                        .contains(user.uid)) {
                      // inviteeIds.add(uid);
                      invitees.insert(0, user);
                    }
                  });
                },
                removeInvitee: (UserModel user) {
                  setState(() {
                    invitees.removeWhere((item) => item.uid == user.uid);
                  });
                },
              ),
            ),
          ),
        ),
      ];

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

    LoadingOverlay.show(context);
    var dbPoll =
        await Provider.of<FirebasePollEvent>(context, listen: false).createPoll(
      pollEventName: eventTitleController.text,
      organizerUid: curUid,
      pollEventDesc: eventDescController.text,
      deadline: deadlineController.text,
      dates: dates,
      locations: locations,
      public: visibility,
      canInvite: canInvite,
      isClosed: false,
    );

    // poll create will return NULL if the poll ALREADY EXISTS
    ret = MyAlertDialog.showAlertIfCondition(
      context: context,
      condition: dbPoll == null,
      title: "Duplicate Poll/Event",
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
      pollEventId: pollId,
      inviteeId: curUid,
    );
    await Future.wait(invitees
        .map((invitee) =>
            Provider.of<FirebasePollEventInvite>(context, listen: false)
                .createPollEventInvite(
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
        title: "New Poll",
        shape: const Border(),
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
      body: MyStepper(
        elevation: 1,
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
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(
          vertical: 10,
          horizontal: MediaQuery.of(context).size.width >= 600
              ? MediaQuery.of(context).size.width / 2 - 300 + 10
              : 10,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).appBarTheme.backgroundColor,
          /*
          border: Border(
            top: BorderSide(
              width: 1.0,
              color: Theme.of(context).dividerColor,
            ),
          ),
           */
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
            SizedBox(width: _activeStepIndex > 0 ? 10 : 0),
            Expanded(
              child: MyButton(
                onPressed: () async {
                  if (_activeStepIndex < (stepList().length - 1)) {
                    setState(() {
                      _activeStepIndex += 1;
                    });
                  } else {
                    await checkAndCreatePoll();
                  }
                },
                text: (_activeStepIndex == stepList().length - 1)
                    ? 'Create'
                    : 'Next',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
