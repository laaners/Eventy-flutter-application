import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/providers/theme_switch.dart';
import 'package:dima_app/screens/search.dart';
import 'package:dima_app/server/firebase_crud.dart';
import 'package:dima_app/server/firebase_follow.dart';
import 'package:dima_app/server/firebase_poll.dart';
import 'package:dima_app/server/firebase_poll_event_invite.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/tables/user_collection.dart';
import 'package:dima_app/widgets/lists_switcher.dart';
import 'package:dima_app/widgets/loading_overlay.dart';
import 'package:dima_app/widgets/loading_spinner.dart';
import 'package:dima_app/widgets/show_snack_bar.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/provider_samples.dart';

import '../widgets/search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scroll = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar("Home"),
      body: Column(
        children: [
          const Text("ok"),
          Expanded(
            child: ListView(
              controller: _scroll,
              children: [
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
                    final dynamicLongLink = await FirebaseDynamicLinks.instance
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
                ListsSwitcher(
                  labels: ["ciao", "come", "stai"],
                  lists: [Text("data1"), Text("data2"), Text("data3")],
                ),
                StreamBuilder(
                  stream: FirebaseCrud.readSnapshot(
                      Provider.of<FirebaseUser>(context, listen: false)
                          .userCollection,
                      "4AxIUlqdkVXYf2fCVGH4DpUb0Dj1"),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<DocumentSnapshot<Object?>> snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingSpinner();
                    }
                    if (snapshot.hasError || snapshot.data == null) {
                      return const Text(
                          "user retrieval failed or non-existent");
                    }
                    UserCollection userData = UserCollection.fromMap(
                      (snapshot.data!.data()) as Map<String, dynamic>,
                    );
                    return Text(userData.name);
                  },
                ),
                const Text("ok"),
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

                TextFormField(),
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

                ElevatedButton(
                    child: const Text('Open search'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SearchPage()),
                      );
                    }),

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

                ElevatedButton(
                  child: const Text('Open search'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SearchPage()),
                    );
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

                // Search user functionality
                TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SearchPage()),
                      );
                    },
                    child: const Text("Search page")),
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

                // Search user functionality
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SearchPage()),
                    );
                  },
                  child: const Text("Search page"),
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
                /*
                TextButton(
                  onPressed: () async {
                    var rows =
                        await Provider.of<PostgresMethods>(context, listen: false)
                            .test(context);
                    for (final row in rows) {
                      debugPrint(row["users"]["username"]);
                    }
                  },
                  child: const Text("Postgres test"),
                ),
                */

                // List DB fetch
                const UsersList2(),

                // long shape
                Center(
                  child: Container(
                    color: Colors.orange,
                    width: 20,
                    height: 1000,
                  ),
                ),
                const Text("ok"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UsersList2 extends StatelessWidget {
  const UsersList2({super.key});

  @override
  Widget build(BuildContext context) {
    CollectionReference users =
        Provider.of<FirebaseUser>(context, listen: false).userCollection;
    var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    return FutureBuilder(
      future: users.get(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var users = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            itemCount: users.docs.length,
            itemBuilder: (context, index) {
              var uid = users.docs[index]["uid"];
              /*
              Provider.of<FirebasePollEventInvite>(context, listen: false)
                  .createPollEventInvite(
                      context: context,
                      pollEventId: "gg_HB6d3gyBuwbG5RY1qK5bvqwdIkb2",
                      inviteeId: uid);
              print("added");
              */
              if (uid == curUid) {
                return Text(users.docs[index]["uid"] + "==" + curUid);
              } else {
                /*
                Provider.of<FirebaseFollow>(context, listen: false)
                    .addFollower(context, curUid, uid, true);
                print("added");
                */
                return Text(users.docs[index]["uid"]);
              }
              // return UserTile(user: users.docs[index]["uid"]);
            },
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        // By default, show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
  }
}

class UserTile2 extends StatelessWidget {
  final UserCollection user;
  const UserTile2({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(0),
      padding: const EdgeInsets.all(1.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 1,
            color: Provider.of<ThemeSwitch>(context).themeData.primaryColor,
          ),
        ),
      ),
      child: ListTile(
        title: Text(
          "UserName: ${user.username}",
          style:
              Provider.of<ThemeSwitch>(context).themeData.textTheme.bodyMedium,
        ),
        subtitle: Text("Name: ${user.name}"),
        leading: const Text("USER:"),
        trailing: const Text("..."),
        onTap: () {
          showSnackBar(context, "In construction...");
        },
      ),
    );
  }
}
