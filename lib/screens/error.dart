import 'package:dima_app/widgets/my_button.dart';
import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ErrorScreen extends StatelessWidget {
  final String errorMsg;
  const ErrorScreen({super.key, required this.errorMsg});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveWrapper(
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              const Image(
                image: AssetImage('images/logo.png'),
                height: 80,
              ),
              Container(padding: const EdgeInsets.only(top: 30)),
              Text(
                "AN ERROR HAS OCCURRED",
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
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
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    // Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
