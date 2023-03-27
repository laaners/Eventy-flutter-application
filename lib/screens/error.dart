import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/my_button.dart';
import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final String errorMsg;
  const ErrorScreen({super.key, required this.errorMsg});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        title: "Error",
        upRightActions: [],
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Image(
              image: AssetImage('images/logo.png'),
              height: 80,
            ),
            Container(padding: const EdgeInsets.only(top: 30)),
            const Center(
              child: Text(
                "AN ERROR HAS OCCURRED",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            Container(padding: const EdgeInsets.only(top: 10)),
            Center(
              child: Text(errorMsg),
            ),
            Container(padding: const EdgeInsets.only(top: 10)),
            Center(
              child: MyButton(
                text: "GO BACK!",
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
