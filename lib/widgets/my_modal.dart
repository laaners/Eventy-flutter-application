import 'package:dima_app/constants/layout_constants.dart';
import 'package:flutter/material.dart';

class MyModal extends StatelessWidget {
  final Widget child;
  final double heightFactor;
  final bool doneCancelMode;
  final VoidCallback onDone;
  final Widget? titleWidget;
  final String? title;

  const MyModal({
    super.key,
    required this.child,
    required this.doneCancelMode,
    required this.onDone,
    required this.heightFactor,
    this.titleWidget,
    this.title,
  });

  static Widget modalWidget({
    required BuildContext context,
    required Widget child,
    required double heightFactor,
    required bool doneCancelMode,
    required VoidCallback onDone,
    Widget? titleWidget,
    String? title,
    bool? shrinkWrap,
  }) {
    return Scrollbar(
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: LayoutConstants.kModalHorizontalPadding),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      doneCancelMode
                          ? Stack(
                              children: [
                                Align(
                                  alignment: const Alignment(-1, 0),
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: const Alignment(0, 0),
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        bottom: 10, top: 10),
                                    alignment: Alignment.center,
                                    width: 80,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(20)),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: const Alignment(1, 0),
                                  child: TextButton(
                                    onPressed: onDone,
                                    child: const Text("Confirm"),
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              margin:
                                  const EdgeInsets.only(bottom: 10, top: 10),
                              alignment: Alignment.center,
                              width: 80,
                              height: 3,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.outline,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(20)),
                              ),
                            ),
                      if (titleWidget != null) titleWidget,
                      if (title != null && title.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 0, top: 8),
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
                      controller: ScrollController(),
                      shrinkWrap: shrinkWrap ?? true,
                      physics: const ClampingScrollPhysics(),
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          child: child,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<dynamic> show({
    required BuildContext context,
    required Widget child,
    required double heightFactor,
    required bool doneCancelMode,
    required VoidCallback onDone,
    Widget? titleWidget,
    String? title,
    bool? shrinkWrap,
  }) async {
    var ris = await showModalBottomSheet(
      useRootNavigator: true,
      isScrollControlled: true,
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) => FractionallySizedBox(
        heightFactor: heightFactor,
        child: doneCancelMode
            ? child
            : modalWidget(
                context: context,
                child: child,
                heightFactor: heightFactor,
                doneCancelMode: doneCancelMode,
                onDone: onDone,
                titleWidget: titleWidget,
                title: title,
                shrinkWrap: shrinkWrap,
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
      titleWidget: titleWidget,
    );
  }
}
