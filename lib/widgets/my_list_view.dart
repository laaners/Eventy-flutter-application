import 'package:dima_app/providers/theme_switch.dart';
import 'package:dima_app/server/postgres_methods.dart';
import 'package:dima_app/widgets/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyListView extends StatelessWidget {
  const MyListView({super.key});

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
              return MyListTile(user: users[index]["users"]);
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

class MyListTile extends StatelessWidget {
  final Map<String, dynamic> user;
  const MyListTile({super.key, required this.user});

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
