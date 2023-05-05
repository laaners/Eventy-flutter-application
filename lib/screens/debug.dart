import 'dart:convert';

import 'package:dima_app/firebase_cruds_testing.dart';
import 'package:dima_app/screens/error.dart';
import 'package:dima_app/server/firebase_crud.dart';
import 'package:dima_app/server/firebase_follow.dart';
import 'package:dima_app/server/firebase_poll.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/messaging.dart';
import 'package:dima_app/server/tables/user_collection.dart';
import 'package:dima_app/widgets/loading_overlay.dart';
import 'package:dima_app/widgets/my_button.dart';
import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/provider_samples.dart';

import '../widgets/logo.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _locationAddrController = TextEditingController();
  List<String> inviteeIds = [];

  @override
  Widget build(BuildContext context) {
    print("rebuild home");
    return Scaffold(
      appBar: MyAppBar(
        title: "Debug",
        upRightActions: [MyAppBar.SearchAction(context)],
      ),
      body: ResponsiveWrapper(
        child: Column(
          children: [
            Text(
              _locationAddrController.text + "ok",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Text("ok"),
            Expanded(
              child: ListView(
                controller: _scroll,
                children: [
                  MyButton(
                    text: "Subscribe to topic",
                    onPressed: () {
                      FirebaseMessaging.instance.subscribeToTopic("finance");
                      print("subscribed");
                    },
                  ),
                  MyButton(
                    text: "Unsubscribe from topic",
                    onPressed: () {
                      FirebaseMessaging.instance
                          .unsubscribeFromTopic("finance");
                      print("unsubscribed");
                    },
                  ),
                  MyButton(
                      text: "send a notification",
                      onPressed: () async {
                        String topic =
                            Provider.of<FirebaseUser>(context, listen: false)
                                .user!
                                .uid;
                        Messaging.sendNotification(
                          topic: topic,
                          title: "title",
                          body: "body",
                        );
                      }),
                  MyButton(
                      text: "delete a poll",
                      onPressed: () async {
                        await Provider.of<FirebasePoll>(context, listen: false)
                            .closePoll(
                                context: context,
                                pollId:
                                    "Event 2 of UsernameId16_FXLaBqT6DhQhPujaHMQE4AKFaXX2");
                      }),
                  MyButton(
                    onPressed: () {
                      FirebaseCrudsTesting.createFollowingFollowers(context);
                    },
                    text: "create followers/following",
                  ),
                  MyButton(
                    onPressed: () {
                      FirebaseCrudsTesting.createPolls(context);
                    },
                    text: "create polls",
                  ),
                  TextButton(
                    onPressed: () async {
                      const String url =
                          "https://eventy.page.link?pollId=gg_HB6d3gyBuwbG5RY1qK5bvqwdIkb2";
                      final dynamicLinkParams = DynamicLinkParameters(
                        link: Uri.parse(url),
                        uriPrefix: "https://eventy.page.link",
                        androidParameters: const AndroidParameters(
                          packageName: "com.example.dima_app",
                        ),
                        iosParameters: const IOSParameters(
                          bundleId: "com.example.dima_app",
                        ),
                      );
                      final dynamicLongLink = await FirebaseDynamicLinks
                          .instance
                          .buildLink(dynamicLinkParams);
                      final ShortDynamicLink dynamicShortLink =
                          await FirebaseDynamicLinks.instance
                              .buildShortLink(dynamicLinkParams);
                      Uri finalUrl = dynamicShortLink.shortUrl;
                      print(finalUrl);
                      print(dynamicLongLink);

                      final instanceLink =
                          await FirebaseDynamicLinks.instance.getInitialLink();
                      // init dynamic link
                    },
                    child: const Text("dynamic link"),
                  ),
                  // StreamBuilder(
                  //   stream: FirebaseCrud.readSnapshot(
                  //       Provider.of<FirebaseUser>(context, listen: false)
                  //           .userCollection,
                  //       "DIfNcKvzaramvCteTHktEzGI22y1"),
                  //   builder: (
                  //     BuildContext context,
                  //     AsyncSnapshot<DocumentSnapshot<Object?>> snapshot,
                  //   ) {
                  //     if (snapshot.connectionState == ConnectionState.waiting) {
                  //       return const LoadingSpinner();
                  //     }
                  //     if (snapshot.hasError || snapshot.data == null) {
                  //       return const Text(
                  //           "user retrieval failed or non-existent");
                  //     }
                  //     UserCollection userData = UserCollection.fromMap(
                  //       (snapshot.data!.data()) as Map<String, dynamic>,
                  //     );
                  //     return Text(userData.name);
                  //   },
                  // ),
                  // const Text("ok"),
                  Consumer<FirebaseUser>(
                    builder: (context, value, child) {
                      return Text("${value.user}");
                    },
                  ),
                  Consumer<FirebaseUser>(
                    builder: (context, value, child) {
                      return Text(value.userData.toString());
                    },
                  ),

                  Text(Provider.of<Something>(context).stringa),
                  // equivalente a quello sopra
                  Text(context.watch<Something>().stringa),
                  Text(Provider.of<String>(context)),

                  // mutable provider
                  // Wrap ONLY the part I want to rebuild in a Consumer of provider type, watch rebuilds everything
                  Consumer<CounterProviderSample>(
                    builder: (context, providerObj, child) {
                      return Text("${providerObj.counter}");
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Provider.of<CounterProviderSample>(context, listen: false)
                          .incrementCounter();
                      // Read inside build should be avoided
                      // context.read<CounterProviderSample>().incrementCounter();
                    },
                    child: const Icon(Icons.add),
                  ),

                  MyButton(
                    text: "Error page",
                    onPressed: () {
                      // TODO: change other calls to error page like this
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const ErrorScreen(errorMsg: 'MY error Message'),
                        ),
                      );
                    },
                  ),

                  MyButton(
                    text: "Time Picker",
                    onPressed: () {
                      showTimePicker(
                          context: context,
                          initialEntryMode: TimePickerEntryMode.input,
                          initialTime: TimeOfDay.fromDateTime(DateTime.now()));
                    },
                  ),

                  MyButton(
                    text: "Date Range Picker",
                    onPressed: () {
                      showDateRangePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(9999));
                    },
                  ),

                  MyButton(
                    text: "Date Picker",
                    onPressed: () {
                      showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(9999));
                    },
                  ),

                  //Stream provider
                  Consumer<int>(
                    builder: (context, providerObj, child) {
                      return Text("$providerObj");
                    },
                  ),
                  Consumer<FirebaseUser>(
                    builder: (context, value, child) {
                      return Column(children: [
                        Text(
                          "USER:\n${value.user}",
                        )
                      ]);
                    },
                  ),

                  Consumer<FirebaseUser>(
                    builder: (context, value, child) {
                      return Text("USERDATA:\n${value.userData.toString()}");
                    },
                  ),

                  TextButton(
                    onPressed: () async {
                      LoadingOverlay.show(context);
                      await Provider.of<FirebaseUser>(context, listen: false)
                          .loginWithEmail(
                        email: "test13@test.it", //"ok@ok.it",
                        password: "password",
                        context: context,
                      );
                      LoadingOverlay.hide(context);
                    },
                    child: const Text("Firebase login"),
                  ),

                  //Future provider
                  Consumer<String>(
                    builder: (context, providerObj, child) {
                      final address = providerObj;
                      return Text("$address dsadsa");
                    },
                  ),

                  // DB test
                  TextButton(
                    onPressed: () async {
                      /*
                      for (var i = 10; i < 30; i++) {
                        await Provider.of<FirebaseUser>(context, listen: false)
                            .signUpWithEmail(
                          email: "test$i@test.it",
                          password: "password",
                          username: "Username$i",
                          name: "name$i",
                          surname: "surname$i",
                          profilePic: "profilePic",
                          context: context,
                        );
                      }
                      */
                      var curUid =
                          Provider.of<FirebaseUser>(context, listen: false)
                              .user!
                              .uid;
                      Provider.of<FirebaseFollow>(context, listen: false)
                          .addFollower(context, curUid, "1", true);
                      Provider.of<FirebaseFollow>(context, listen: false)
                          .removeFollower(context, curUid, "1", true);
                    },
                    child: const Text("Firebase test"),
                  ),

                  // DB test
                  TextButton(
                    onPressed: () async {
                      var curUid =
                          Provider.of<FirebaseUser>(context, listen: false)
                              .user!
                              .uid;
                      Provider.of<FirebaseFollow>(context, listen: false)
                          .addFollower(context, curUid, "1", true);
                      Provider.of<FirebaseFollow>(context, listen: false)
                          .removeFollower(context, curUid, "1", true);
                    },
                    child: const Text("Firebase test"),
                  ),

                  TextButton(
                    onPressed: () async {
                      LoadingOverlay.show(context);
                      await Provider.of<FirebaseUser>(context, listen: false)
                          .loginWithEmail(
                        email: "test13@test.it", //"ok@ok.it",
                        password: "password",
                        context: context,
                      );
                      LoadingOverlay.hide(context);
                    },
                    child: const Text("Firebase login"),
                  ),
                  TextButton(
                    onPressed: () async {
                      LoadingOverlay.show(context);
                      // overlay.show();
                      var document = await FirebaseCrud.readDoc(
                        Provider.of<FirebaseUser>(context, listen: false)
                            .userCollection,
                        "IrI8s7a6WeVUgF3fAYd99YHdnqh2",
                      );
                      LoadingOverlay.hide(context);
                      UserCollection usertest = UserCollection.fromMap(
                        document?.data() as Map<String, dynamic>,
                      );
                      print(document?.exists);
                      print(usertest.email);
                      // overlay.hide();

                      var snapshots = await FirebaseCrud.readSnapshot(
                        Provider.of<FirebaseUser>(context, listen: false)
                            .userCollection,
                        "IrI8s7a6WeVUgF3fAYd99YHdnqh2",
                      );
                      snapshots?.listen(
                        (event) => print("current data: ${event.data()}"),
                        onError: (error) => print("Listen failed: $error"),
                      );
                    },
                    child: const Text("Firebase get"),
                  ),
                  TextButton(
                    onPressed: () async {
                      await Provider.of<FirebaseUser>(context, listen: false)
                          .signOut(context);
                    },
                    child: const Text("Firebase sign out"),
                  ),
                  TextButton(
                    onPressed: () async {
                      await Provider.of<FirebaseUser>(context, listen: false)
                          .deleteAccount(context);
                    },
                    child: const Text("Firebase delete"),
                  ),

                  Container(
                    color: Theme.of(context).canvasColor,
                    child: const Text("canvas color"),
                  ),
                  Container(
                    color: Theme.of(context).cardColor,
                    child: const Text("card color"),
                  ),
                  Container(
                    color: Theme.of(context).dialogBackgroundColor,
                    child: const Text("dialog bg color"),
                  ),
                  Container(
                    color: Theme.of(context).disabledColor,
                    child: const Text("disabled color"),
                  ),
                  Container(
                    color: Theme.of(context).dividerColor,
                    child: const Text("divider color"),
                  ),
                  Container(
                    color: Theme.of(context).focusColor,
                    child: const Text("focus color"),
                  ),
                  Container(
                    color: Theme.of(context).highlightColor,
                    child: const Text("highlight color"),
                  ),
                  Container(
                    color: Theme.of(context).hintColor,
                    child: const Text("hint color"),
                  ),
                  Container(
                    color: Theme.of(context).hoverColor,
                    child: const Text("hover color"),
                  ),
                  Container(
                    color: Theme.of(context).indicatorColor,
                    child: const Text(
                      "indicator color",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Container(
                    color: Theme.of(context).primaryColor,
                    child: const Text("primary color"),
                  ),
                  Container(
                    color: Theme.of(context).primaryColorDark,
                    child: const Text(
                      "primary dark color",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Container(
                    color: Theme.of(context).primaryColorLight,
                    child: const Text("primary light color"),
                  ),
                  Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: const Text(
                      "scaffold bg color",
                    ),
                  ),
                  Container(
                    color: Theme.of(context).splashColor,
                    child: const Text("splash color"),
                  ),
                  Container(
                    color: Theme.of(context).shadowColor,
                    child: const Text(
                      "shadow color",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Container(
                    color: Theme.of(context).unselectedWidgetColor,
                    child: const Text("unselected widget color"),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.error,
                    child: const Text("colorsheme error color"),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.background,
                    child: const Text("colorsheme bg color"),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.onBackground,
                    child: const Text("colorsheme on bg color"),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.onError,
                    child: const Text("colorsheme on error color"),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.onPrimary,
                    child: const Text("colorsheme onprimary color"),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.onSecondary,
                    child: const Text("colorsheme onsecondary color"),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.onSurface,
                    child: const Text("colorsheme on surface color"),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.primary,
                    child: const Text("colorsheme primary color"),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.secondary,
                    child: const Text("colorsheme error color"),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.inverseSurface,
                    child: const Text("colorsheme inverse surface color"),
                  ),

                  Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: const Text("colorsheme surface color"),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    child: const Text("colorsheme on error container color"),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    child: const Text("colorsheme on primary container color"),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    child:
                        const Text("colorsheme on secondary container color"),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    child: const Text("colorsheme on surface variant color"),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: const Text("colorsheme primary container color"),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: const Text("colorsheme secondary container color"),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: const Text("colorsheme surface variant color"),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.background,
                    child: const Text("colorsheme background color"),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.tertiary,
                    child: const Text("colorsheme tertiary color"),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.onTertiary,
                    child: const Text("colorsheme on tertiary color"),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    child: const Text("colorsheme tertiary container color"),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                    child: const Text("colorsheme on tertiary container color"),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.scrim,
                    child: const Text("colorsheme scrim color"),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.outline,
                    child: const Text("colorsheme outline color"),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    child: const Text("colorsheme outline variant color"),
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                  EventyLogo(),
                  Container(
                    child: Image.asset('images/logo.png'),
                  ),
                  // Generate samples to display of all Theme.of(context).textTheme fonts available
                  Text("Normal text"),
                  Text('textTheme.bodyLarge text',
                      style: Theme.of(context).textTheme.bodyLarge),
                  Text('textTheme.bodyMedium text',
                      style: Theme.of(context).textTheme.bodyMedium),
                  Text('textTheme.bodySmall text',
                      style: Theme.of(context).textTheme.bodySmall),
                  Text('textTheme.displayLarge text',
                      style: Theme.of(context).textTheme.displayLarge),
                  Text('textTheme.displayMedium text',
                      style: Theme.of(context).textTheme.displayMedium),
                  Text('textTheme.displaySmall text',
                      style: Theme.of(context).textTheme.displaySmall),
                  Text('textTheme.headlineLarge text',
                      style: Theme.of(context).textTheme.headlineLarge),
                  Text('textTheme.headlineMedium text',
                      style: Theme.of(context).textTheme.headlineMedium),
                  Text('textTheme.headlineSmall text',
                      style: Theme.of(context).textTheme.headlineSmall),
                  Text('textTheme.labelLarge text',
                      style: Theme.of(context).textTheme.labelLarge),
                  Text('textTheme.labelMedium text',
                      style: Theme.of(context).textTheme.labelMedium),
                  Text('textTheme.labelSmall text',
                      style: Theme.of(context).textTheme.labelSmall),
                  Text('textTheme.titleLarge text',
                      style: Theme.of(context).textTheme.titleLarge),
                  Text('textTheme.titleMedium text',
                      style: Theme.of(context).textTheme.titleMedium),
                  Text('textTheme.titleSmall text',
                      style: Theme.of(context).textTheme.titleSmall),
                  Text('primaryTextTheme.bodyLarge text',
                      style: Theme.of(context).primaryTextTheme.bodyLarge),
                  Text('primaryTextTheme.bodyMedium text',
                      style: Theme.of(context).primaryTextTheme.bodyMedium),
                  Text('primaryTextTheme.bodySmall text',
                      style: Theme.of(context).primaryTextTheme.bodySmall),
                  Text('primaryTextTheme.displayLarge text',
                      style: Theme.of(context).primaryTextTheme.displayLarge),
                  Text('primaryTextTheme.displayMedium text',
                      style: Theme.of(context).primaryTextTheme.displayMedium),
                  Text('primaryTextTheme.displaySmall text',
                      style: Theme.of(context).primaryTextTheme.displaySmall),
                  Text('primaryTextTheme.headlineLarge text',
                      style: Theme.of(context).primaryTextTheme.headlineLarge),
                  Text('primaryTextTheme.headlineMedium text',
                      style: Theme.of(context).primaryTextTheme.headlineMedium),
                  Text('primaryTextTheme.headlineSmall text',
                      style: Theme.of(context).primaryTextTheme.headlineSmall),
                  Text('primaryTextTheme.labelLarge text',
                      style: Theme.of(context).primaryTextTheme.labelLarge),
                  Text('primaryTextTheme.labelMedium text',
                      style: Theme.of(context).primaryTextTheme.labelMedium),
                  Text('primaryTextTheme.labelSmall text',
                      style: Theme.of(context).primaryTextTheme.labelSmall),
                  Text('primaryTextTheme.titleLarge text',
                      style: Theme.of(context).primaryTextTheme.titleLarge),
                  Text('primaryTextTheme.titleMedium text',
                      style: Theme.of(context).primaryTextTheme.titleMedium),
                  Text('primaryTextTheme.titleSmall text',
                      style: Theme.of(context).primaryTextTheme.titleSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
