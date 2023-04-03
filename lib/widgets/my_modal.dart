import 'package:dima_app/widgets/responsive_wrapper.dart';
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
        doneCancelMode
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    alignment: Alignment.topRight,
                    margin: const EdgeInsets.only(left: 15, top: 0),
                    child: InkWell(
                      child: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 30,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 15, top: 8),
                          alignment: Alignment.center,
                          width: 80,
                          height: 3,
                          child: Text("text"),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                        if (title.isNotEmpty)
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium,
                          )
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.topRight,
                    margin: const EdgeInsets.only(right: 15, top: 0),
                    child: InkWell(
                      onTap: onDone,
                      child: const Icon(
                        Icons.done,
                        color: Colors.green,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 15, top: 8),
                          alignment: Alignment.center,
                          width: 80,
                          height: 3,
                          decoration: BoxDecoration(
                            // color: Palette.greyColor.withOpacity(0.5),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                        if (title.isNotEmpty)
                          Text(
                            title,
                            style: Theme.of(context).textTheme.headlineMedium,
                          )
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
                      margin: EdgeInsets.only(top: 15),
                      child: child,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static void show({
    required BuildContext context,
    required Widget child,
    required double heightFactor,
    required bool doneCancelMode,
    required VoidCallback onDone,
    required String title,
  }) async {
    await showModalBottomSheet(
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
