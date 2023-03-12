import 'package:dima_app/widgets/my_button.dart';
import 'package:flutter/material.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';

class EventPollSwitch extends StatefulWidget {
  const EventPollSwitch({super.key});

  @override
  State<EventPollSwitch> createState() => _EventPollSwitchState();
}

class _EventPollSwitchState extends State<EventPollSwitch> {
  bool _displayEvents = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedContainer(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(30)),
                //color: const Color.fromARGB(255, 208, 207, 207),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 10,
                    offset: _displayEvents
                        ? const Offset(-10, 0)
                        : const Offset(10, 0),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 500),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      width: 100,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _displayEvents = true;
                          });
                        },
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          backgroundColor: !_displayEvents
                              ? const MaterialStatePropertyAll(Colors.grey)
                              : const MaterialStatePropertyAll(Colors.blue),
                        ),
                        child: const Text("Events"),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      width: 100,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _displayEvents = false;
                          });
                        },
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          backgroundColor: _displayEvents
                              ? const MaterialStatePropertyAll(Colors.grey)
                              : const MaterialStatePropertyAll(Colors.blue),
                        ),
                        child: Container(
                            width: 100,
                            alignment: Alignment.center,
                            child: const Text("Polls")),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
        Container(
          child: _displayEvents ? const Text("Events") : const Text("Pools"),
        )
      ],
    );
  }
}
