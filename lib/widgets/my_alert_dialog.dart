import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'my_button.dart';

// OK only alert dialog, usually for errors or warning
class MyAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  const MyAlertDialog({
    super.key,
    required this.title,
    required this.content,
  });

  static bool showAlertIfCondition(
    BuildContext context,
    bool condition,
    String title,
    String content,
  ) {
    if (condition) {
      showDialog<String>(
          context: context,
          builder: (BuildContext context) => MyAlertDialog(
                title: title,
                content: content,
              ));
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        MyButton(
          text: '   OK   ',
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}
