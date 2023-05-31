import 'package:flutter/material.dart';

import 'logo.dart';

class EmptyList extends StatelessWidget {
  final String emptyMsg;
  const EmptyList({super.key, required this.emptyMsg});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(top: 30),
        child: ListView(
          children: [
            const EventyLogo(extWidth: 80),
            Container(height: 20),
            Text(emptyMsg, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
