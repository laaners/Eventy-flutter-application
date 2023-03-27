import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class ListsSwitcher extends StatefulWidget {
  final List<String> labels;
  final List<Widget> lists;

  const ListsSwitcher({
    super.key,
    required this.labels,
    required this.lists,
  });

  @override
  State<ListsSwitcher> createState() => _ListsSwitcherState();
}

class _ListsSwitcherState extends State<ListsSwitcher> {
  int _listIndex = 0;
  int _showIndex = 0;

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
                    left: _listIndex * 100,
                    right: widget.labels.length * 100 - (_listIndex + 1) * 100,
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
                    children: widget.labels.mapIndexed((index, label) {
                      return TextButton(
                        onPressed: () {
                          setState(() {
                            _listIndex = index;
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
                          label,
                          style: TextStyle(
                              color: _listIndex == index
                                  ? Colors.white
                                  : Colors.grey),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
        // todo: add widgets event_list and poll_list
        ...widget.lists.mapIndexed((index, child) {
          return Visibility(
            maintainState:
                true, // in this way the child is not rebuilt every time we switch
            visible: _listIndex == index,
            child: Container(
              child: child,
            ),
          );
        }).toList(),
      ],
    );
  }
}
