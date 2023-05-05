import 'package:flutter/material.dart';

// OK only alert dialog, usually for errors or warning
class MyAlertDialog {
  static bool showAlertIfCondition({
    required BuildContext context,
    required bool condition,
    required String title,
    required String content,
  }) {
    if (condition) {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(title),
          content: Text(
            content,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return true;
    }
    return false;
  }

  static Future<bool> showAlertConfirmCancel({
    required BuildContext context,
    required String title,
    required String content,
    required String trueButtonText,
  }) async {
    dynamic ris = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(
          content,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStatePropertyAll(Theme.of(context).colorScheme.error),
            ),
            onPressed: () {
              Navigator.pop(context, "confirm");
            },
            child: Text(
              trueButtonText,
              style: TextStyle(color: Theme.of(context).colorScheme.onError),
            ),
          ),
        ],
      ),
    );
    return ris != null;
  }
}
