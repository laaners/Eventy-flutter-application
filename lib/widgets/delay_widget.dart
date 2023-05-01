import 'package:flutter/material.dart';

import 'loading_spinner.dart';

class DelayWidget extends StatefulWidget {
  final Widget child;
  const DelayWidget({super.key, required this.child});

  @override
  State<DelayWidget> createState() => _DelayWidgetState();
}

class _DelayWidgetState extends State<DelayWidget> {
  final Future _future = Future.delayed(const Duration(milliseconds: 150));

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingSpinner();
        }
        return widget.child;
      },
    );
  }
}
