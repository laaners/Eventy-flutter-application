import 'package:dima_app/server/tables/poll_collection.dart';
import 'package:dima_app/widgets/poll_list.dart';
import 'package:flutter/material.dart';

class EventPollSwitch extends StatefulWidget {
  final String userUid;

  const EventPollSwitch({super.key, required this.userUid});

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
            Container(
              height: 37,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: const BorderRadius.all(Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurStyle: BlurStyle.inner,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  AnimatedPositioned(
                    left: _displayEvents ? 0 : 100,
                    right: _displayEvents ? 100 : 0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.fastOutSlowIn,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.blue,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurStyle: BlurStyle.inner,
                          ),
                        ],
                      ),
                      child: const SizedBox(
                        height: 30,
                        width: 100,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _displayEvents = true;
                          });
                        },
                        style: ButtonStyle(
                          fixedSize: MaterialStateProperty.all(
                              const Size.fromWidth(100)),
                          alignment: Alignment.center,
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                        child: Text(
                          "Events",
                          style: TextStyle(
                              color:
                                  _displayEvents ? Colors.white : Colors.grey),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(
                            () {
                              _displayEvents = false;
                            },
                          );
                        },
                        style: ButtonStyle(
                          fixedSize: MaterialStateProperty.all(
                              const Size.fromWidth(100)),
                          alignment: Alignment.center,
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                        child: Text(
                          "Polls",
                          style: TextStyle(
                              color:
                                  !_displayEvents ? Colors.white : Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        // todo: add widgets event_list and poll_list
        Container(
          child: _displayEvents
              ? const Text("Events")
              : PollList(
                  userUid: widget.userUid,
                  height: 400,
                ),
        )
      ],
    );
  }
}
