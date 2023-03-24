import 'package:flutter/material.dart';

class MyTitle extends StatelessWidget {
  MyTitle({super.key, required this.text, required this.alignment});

  String text;
  Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      margin: const EdgeInsets.fromLTRB(22, 0, 0, 0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
