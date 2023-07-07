import 'package:dima_app/widgets/delay_widget.dart';
import 'package:dima_app/widgets/tablet_navigation_rail.dart';
import 'package:flutter/material.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final bool? hideNavigation;
  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.hideNavigation,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DelayWidget(
        child: MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                        .size
                        .shortestSide >=
                    600 &&
                (hideNavigation != true)
            ? Row(
                children: [
                  TabletNavigationRail(),
                  Expanded(
                    child: Container(
                      alignment: Alignment.topCenter,
                      decoration: BoxDecoration(
                        color: Theme.of(context).appBarTheme.backgroundColor,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                  color: Theme.of(context).appBarTheme.backgroundColor,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    child: child,
                  ),
                ),
              ),
      ),
    );
  }
}
