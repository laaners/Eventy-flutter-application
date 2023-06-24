import 'package:flutter/material.dart';

import 'logo.dart';

class EmptyList extends StatelessWidget {
  final String emptyMsg;
  final String? title;
  final Widget? button;
  const EmptyList({
    super.key,
    required this.emptyMsg,
    this.title,
    this.button,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: title != null ? 0 : 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (title != null)
            Text(
              title!,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
          if (title != null) const SizedBox(height: 20),
          const EventyLogo(extWidth: 80),
          const SizedBox(height: 20),
          FractionallySizedBox(
            alignment: Alignment.topCenter,
            widthFactor: 0.8,
            child: Text(
              emptyMsg,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 20),
          if (button != null) button!
        ],
      ),
    );
  }
}
