import 'package:dima_app/constants/layout_constants.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:dima_app/widgets/logo.dart';
import 'package:dima_app/widgets/my_button.dart';
import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ErrorScreen extends StatelessWidget {
  final String errorMsg;
  const ErrorScreen({super.key, this.errorMsg = ""});

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
                  const SizedBox(height: 180, child: EventyLogo(extWidth: 180)),
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
                  const SizedBox(
                    height: 40,
                  ),
                  MyButton(
                    text: "GO BACK!",
                    onPressed: () async {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                        // Navigator.of(context).popUntil((route) => route.isFirst);
                      } else {
                        await Provider.of<FirebaseUser>(context, listen: false)
                            .signOut();
                      }
                    },
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
