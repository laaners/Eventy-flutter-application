import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_app/providers/theme_switch.dart';
import 'package:dima_app/screens/search.dart';
import 'package:dima_app/server/firebase_methods.dart';
import 'package:dima_app/widgets/loading_overlay.dart';
import 'package:dima_app/widgets/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/provider_samples.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar("Home"),
      body: ListView(
        children: [
          const Text("ok"),
          Consumer<FirebaseMethods>(
            builder: (context, value, child) {
              return Text("${value.user}");
            },
          ),
          Consumer<FirebaseMethods>(
            builder: (context, value, child) {
              return Text("${value.userData}");
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
                  MaterialPageRoute(builder: (context) => const SearchPage()),
                );
              }),

          //Stream provider
          Consumer<int>(
            builder: (context, providerObj, child) {
              return Text("$providerObj");
            },
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
              for (var i = 10; i < 30; i++) {
                await Provider.of<FirebaseMethods>(context, listen: false)
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
            },
            child: const Text("Firebase test"),
          ),

          // Search user functionality
          TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchPage()),
                );
              },
              child: const Text("Search page")),

          TextButton(
            onPressed: () async {
              LoadingOverlay.show(context);
              await Provider.of<FirebaseMethods>(context, listen: false)
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
              var document =
                  await Provider.of<FirebaseMethods>(context, listen: false)
                      .readDoc(
                Provider.of<FirebaseMethods>(context, listen: false)
                    .userCollection,
                "IrI8s7a6WeVUgF3fAYd99YHdnqh2",
              );
              LoadingOverlay.hide(context);
              print(document?.data());
              print(document?.exists);
              // overlay.hide();

              var snapshots =
                  await Provider.of<FirebaseMethods>(context, listen: false)
                      .readSnapshot(
                Provider.of<FirebaseMethods>(context, listen: false)
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
              var curUid = Provider.of<FirebaseMethods>(context, listen: false)
                  .user!
                  .uid;
              await Provider.of<FirebaseMethods>(context, listen: false)
                  .addFollower(
                context,
                curUid,
                "TEST",
              );
            },
            child: const Text("Firebase add follower"),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<FirebaseMethods>(context, listen: false)
                  .signOut(context);
            },
            child: const Text("Firebase sign out"),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<FirebaseMethods>(context, listen: false)
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
          const UsersList(),

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
    );
  }
}

class UsersList extends StatelessWidget {
  const UsersList({super.key});

  @override
  Widget build(BuildContext context) {
    CollectionReference users =
        Provider.of<FirebaseMethods>(context, listen: false).userCollection;
    var curUid = Provider.of<FirebaseMethods>(context, listen: false).user!.uid;
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
              if (uid == curUid) {
                return Text(users.docs[index]["uid"] + "==" + curUid);
              } else {
                /*
                Provider.of<FirebaseMethods>(context, listen: false)
                    .addFollower(context, curUid, uid);
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

class UserTile extends StatelessWidget {
  final Map<String, dynamic> user;
  const UserTile({super.key, required this.user});

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
          "UserName: ${user["username"]}",
          style:
              Provider.of<ThemeSwitch>(context).themeData.textTheme.bodyMedium,
        ),
        subtitle: Text("Name: ${user["name"]}"),
        leading: Text("USER:"),
        trailing: Text("..."),
        onTap: () {
          showSnackBar(context, "In construction...");
        },
      ),
    );
  }
}
