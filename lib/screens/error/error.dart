import 'package:dima_app/constants/layout_constants.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/logo.dart';
import 'package:dima_app/widgets/my_button.dart';
import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ErrorScreen extends StatelessWidget {
  final String? errorMsg;
  final bool? noButton;
  const ErrorScreen({super.key, this.errorMsg, this.noButton});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveWrapper(
        child: Center(
          child: Scrollbar(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              child: ListView(
                controller: ScrollController(),
                shrinkWrap: true,
                children: [
                  Text(
                    "AN ERROR HAS OCCURRED",
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 100, child: EventyLogo(extWidth: 100)),
                  const SizedBox(height: 20),
                  FractionallySizedBox(
                    alignment: Alignment.topCenter,
                    widthFactor: 0.8,
                    child: Text(
                      // errorMsg ?? "Check your connection and try again!",
                      "Check your connection and try again!",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (noButton != null && noButton == false)
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: LayoutConstants.kHorizontalPadding),
                      child: MyButton(
                        text: "GO BACK!",
                        onPressed: () async {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                            // Navigator.of(context).popUntil((route) => route.isFirst);
                          } else {
                            await Provider.of<FirebaseUser>(context,
                                    listen: false)
                                .signOut();
                          }
                        },
                      ),
                    ),
                  Container(height: LayoutConstants.kPaddingFromCreate),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
