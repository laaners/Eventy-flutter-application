import 'package:flutter/material.dart';

import 'logo.dart';

class EmptyList extends StatelessWidget {
  final String emptyMsg;
  const EmptyList({super.key, required this.emptyMsg});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const EventyLogo(extWidth: 80),
          Container(height: 20),
          Text(
            emptyMsg,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
