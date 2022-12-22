import 'package:dima_app/providers/theme_switch.dart';
import 'package:dima_app/server/date_methods.dart';
import 'package:dima_app/themes/palette.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/my_list_view.dart';
import 'package:dima_app/widgets/my_text_field.dart';
import 'package:flutter/cupertino.dart';
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

  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController pincode = TextEditingController();

  // Basics
  TextEditingController eventTitle = TextEditingController();
  TextEditingController eventDesc = TextEditingController();
  TextEditingController deadlineController = TextEditingController();

  late List<Location> locations;

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();
    deadlineController.text = DateFormat("yyyy-MM-dd HH:00:00").format(
      DateTime(now.year, now.month, now.day + 1),
    );
    locations = [];
  }

  List<Container> locationsList() {
    List<Container> locationsList = [];
    for (var i = 0; i < locations.length; i++) {
      locationsList.add(
        Container(
          padding: const EdgeInsets.symmetric(vertical: 1.0),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                width: 1,
                color: Palette.greyColor,
              ),
            ),
          ),
          child: ListTile(
            title: Text(
              locations[i].name,
              style: TextStyle(
                color: Provider.of<ThemeSwitch>(context).themeData.primaryColor,
              ),
            ),
            leading: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Palette.lightBGColor,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.add_location_alt,
                color: Palette.blueColor,
              ),
            ),
            onTap: () {
              showCupertinoModalPopup(
                context: context,
                builder: (context) => FractionallySizedBox(
                  heightFactor: 0.9,
                  child: Container(
                    color: Provider.of<ThemeSwitch>(context, listen: false)
                        .themeData
                        .scaffoldBackgroundColor,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.dateAndTime,
                      minimumDate: DateTime.now(),
                      initialDateTime: DateFormatter.string2DateTime(
                          deadlineController.text),
                      minuteInterval: 5,
                      use24hFormat: true,
                      onDateTimeChanged: (pickedDate) {
                        setState(() {
                          deadlineController.text =
                              DateFormatter.dateTime2String(pickedDate);
                        });
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
    return locationsList;
  }

  List<Step> stepList() => [
        Step(
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
          content: Column(
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: const Text(
                  "Title",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: MyTextField(
                  maxLength: 40,
                  maxLines: 1,
                  hintText: "What's the occasion?",
                  controller: eventTitle,
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                child: const Text(
                  "Description (optional)",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: MyTextField(
                  maxLength: 200,
                  maxLines: 7,
                  hintText: "Describe what this event is about",
                  controller: eventDesc,
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                child: const Text(
                  "Deadline",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              TextField(
                style: TextStyle(
                  color: Provider.of<ThemeSwitch>(context, listen: false)
                      .themeData
                      .primaryColor,
                ),
                decoration: const InputDecoration(
                  icon: Icon(
                    Icons.calendar_today,
                    color: Palette.greyColor,
                  ),
                  border: InputBorder.none,
                ),
                readOnly: true,
                controller: deadlineController,
                onTap: () async {
                  showModalBottomSheet(
                    useRootNavigator: true,
                    isScrollControlled: true,
                    context: context,
                    builder: (context) => FractionallySizedBox(
                      heightFactor: 0.4,
                      child: Container(
                        color: Provider.of<ThemeSwitch>(context, listen: false)
                            .themeData
                            .scaffoldBackgroundColor,
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.dateAndTime,
                          minimumDate: DateTime.now(),
                          initialDateTime: DateFormatter.string2DateTime(
                              deadlineController.text),
                          minuteInterval: 5,
                          use24hFormat: true,
                          onDateTimeChanged: (pickedDate) {
                            setState(() {
                              deadlineController.text =
                                  DateFormatter.dateTime2String(pickedDate);
                            });
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Step(
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
          content: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                alignment: Alignment.topLeft,
                child: const Text(
                  "Locations",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 1.0),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      width: 1,
                      color: Palette.greyColor,
                    ),
                  ),
                ),
                child: ListTile(
                  title: const Text(
                    "Add a location",
                    style: TextStyle(
                      color: Palette.blueColor,
                    ),
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Palette.lightBGColor,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.add_location_alt,
                      color: Palette.blueColor,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      locations.add(
                        Location(
                          'Location ${locations.length}',
                          'A description for location ${locations.length}',
                          'site for ${locations.length}',
                        ),
                      );
                    });
                    showModalBottomSheet(
                      useRootNavigator: true,
                      isScrollControlled: true,
                      context: context,
                      builder: (context) => FractionallySizedBox(
                        heightFactor: 0.9,
                        child: Container(
                          margin: const EdgeInsets.all(20),
                          child: ListView(
                            children: [
                              Container(
                                alignment: Alignment.topLeft,
                                child: const Text(
                                  "Address",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                height: 600,
                                color: Colors.orange,
                              ),
                              Container(
                                alignment: Alignment.topLeft,
                                child: const Text(
                                  "Title",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: MyTextField(
                                  maxLength: 40,
                                  maxLines: 1,
                                  hintText: "What's the occasion?",
                                  controller: eventTitle,
                                ),
                              ),
                              Container(
                                alignment: Alignment.topLeft,
                                child: const Text(
                                  "Description (optional)",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: MyTextField(
                                  maxLength: 200,
                                  maxLines: 7,
                                  hintText: "Describe what this event is about",
                                  controller: eventDesc,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              ...locationsList(),
            ],
          ),
        ),
        Step(
          isActive: _activeStepIndex >= 2,
          title: const Text(""),
          label: const Text("Dates"),
          content: Column(
            children: [
              DatePickerDialog(
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2023),
              ),
            ],
          ),
        ),
        Step(
          isActive: _activeStepIndex >= 3,
          title: const Text(''),
          label: const Text("Invite"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Name: ${name.text}'),
              Text('Email: ${email.text}'),
              const Text('Password: *****'),
              Text('Address : ${address.text}'),
              Text('PinCode : ${pincode.text}'),
            ],
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar("New Event"),
      body: Theme(
        data: ThemeData(
          canvasColor: Provider.of<ThemeSwitch>(context)
              .themeData
              .scaffoldBackgroundColor,
          shadowColor: Colors.transparent,
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: Colors.purpleAccent,
              ),
        ),
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: _activeStepIndex,
          steps: stepList(),
          onStepContinue: () {
            if (_activeStepIndex < (stepList().length - 1)) {
              setState(() {
                _activeStepIndex += 1;
              });
            } else {
              print('Submited');
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
              margin: EdgeInsets.only(bottom: 50, top: 20),
              child: Row(
                children: [
                  if (_activeStepIndex > 0)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: controls.onStepCancel,
                        child: const Text('Back'),
                      ),
                    ),
                  SizedBox(
                    width: _activeStepIndex > 0 ? 10 : 0,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controls.onStepContinue,
                      child: (isLastStep)
                          ? const Text('Submit')
                          : const Text('Next'),
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

class Location {
  final String name;
  final String description;
  final String site;
  Location(this.name, this.description, this.site);
}
