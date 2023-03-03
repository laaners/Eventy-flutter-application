import 'package:dima_app/providers/theme_switch.dart';
import 'package:dima_app/screens/event_create/my_stepper.dart';
import 'package:dima_app/screens/event_create/step_basics.dart';
import 'package:dima_app/screens/event_create/step_dates.dart';
import 'package:dima_app/screens/event_create/step_places.dart';
import 'package:dima_app/server/date_methods.dart';
import 'package:dima_app/themes/palette.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/my_button.dart';
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

  // stepPlaces
  List<Location> locations = [];

  // stepDates;
  Map<String, dynamic> dates = {};

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
          content: StepBasics(
            eventTitleController: eventTitleController,
            eventDescController: eventDescController,
            deadlineController: deadlineController,
            setDeadline: (DateTime pickedDate) {
              setState(() {
                deadlineController.text =
                    DateFormatter.dateTime2String(pickedDate);
              });
            },
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
              }),
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
                    dates[day].removeWhere((key, value) => key == slot);
                    if (dates[day].isEmpty) {
                      dates.removeWhere((key, value) => key == day);
                    }
                  }
                }
              });
            },
            deadlineController: deadlineController,
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
          "New Event, filter dates before deadline at the end!!!"),
      body: Theme(
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
          onStepContinue: () {
            if (_activeStepIndex < (stepList().length - 1)) {
              setState(() {
                _activeStepIndex += 1;
              });
            } else {
              print(eventTitleController.text);
              print(eventDescController.text);
              print(deadlineController.text);
              print(locations.toString());
              print(dates);
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
    );
  }
}