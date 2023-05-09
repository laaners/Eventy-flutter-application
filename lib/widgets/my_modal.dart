import 'package:dima_app/widgets/my_button.dart';
import 'package:flutter/material.dart';

class MyModal extends StatelessWidget {
  final Widget child;
  final double heightFactor;
  final bool doneCancelMode;
  final VoidCallback onDone;
  final String title;
  const MyModal({
    super.key,
    required this.child,
    required this.doneCancelMode,
    required this.onDone,
    required this.heightFactor,
    required this.title,
  });

  static Widget modalWidget({
    required BuildContext context,
    required Widget child,
    required double heightFactor,
    required bool doneCancelMode,
    required VoidCallback onDone,
    required String title,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 10, top: 10),
                    alignment: Alignment.center,
                    width: 80,
                    height: 3,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outline,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                  if (title.isNotEmpty)
                    Container(
                      margin:
                          const EdgeInsets.only(bottom: 0, top: 8, left: 15),
                      alignment: Alignment.topLeft,
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        Expanded(
          child: Container(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Container(
                margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: ListView(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 15),
                      child: child,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        /*
        Container(
          margin: const EdgeInsets.all(15),
          child: doneCancelMode
              ? Row(
                  children: [
                    Expanded(
                      child: MyButton(
                        text: "CLOSE",
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MyButton(
                        text: "CLOSE",
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                )
              : MyButton(
                  text: "CLOSE",
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
        )
        */
      ],
    );
  }

  static Future<dynamic> show({
    required BuildContext context,
    required Widget child,
    required double heightFactor,
    required bool doneCancelMode,
    required VoidCallback onDone,
    required String title,
  }) async {
    var ris = await showModalBottomSheet(
      useRootNavigator: true,
      isScrollControlled: true,
      context: context,
      builder: (context) => FractionallySizedBox(
        heightFactor: heightFactor,
        child: modalWidget(
          context: context,
          child: child,
          heightFactor: heightFactor,
          doneCancelMode: doneCancelMode,
          onDone: onDone,
          title: title,
        ),
      ),
    );
    return ris;
  }

  @override
  Widget build(BuildContext context) {
    return modalWidget(
      context: context,
      child: child,
      heightFactor: heightFactor,
      doneCancelMode: doneCancelMode,
      onDone: onDone,
      title: title,
    );
  }
}
