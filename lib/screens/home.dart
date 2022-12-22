import 'package:dima_app/providers/theme_switch.dart';
import 'package:dima_app/widgets/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/server/postgres_methods.dart';
import 'package:dima_app/provider_samples.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar("Home"),
      body: ListView(
        children: [
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
              var rows =
                  await Provider.of<PostgresMethods>(context, listen: false)
                      .test(context);
              for (final row in rows) {
                debugPrint(row["users"]["username"]);
              }
            },
            child: const Text("Postgres test"),
          ),

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
    return FutureBuilder(
      future: Provider.of<PostgresMethods>(context, listen: false).users(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var users = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            itemCount: users.length,
            itemBuilder: (context, index) {
              return UserTile(user: users[index]["users"]);
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
